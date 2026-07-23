# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'ipaddr'
require_relative 'version'
require_relative 'params'
require_relative 'cards'
require_relative 'decks'
require_relative 'note_types'
require_relative 'notes'
require_relative 'media'
require_relative 'graphical'
require_relative 'statistics'
require_relative 'miscellaneous'

module AnkiConnect
  # Main client class that includes all API modules and provides
  # the core request mechanism.
  class Client
    include AnkiConnect::Client::Params
    include AnkiConnect::Client::Cards
    include AnkiConnect::Client::Decks
    include AnkiConnect::Client::NoteTypes
    include AnkiConnect::Client::Notes
    include AnkiConnect::Client::Media
    include AnkiConnect::Client::Graphical
    include AnkiConnect::Client::Statistics
    include AnkiConnect::Client::Miscellaneous

    # @return [String] AnkiConnect server host
    attr_reader :host
    # @return [Integer] AnkiConnect server port
    attr_reader :port
    # @return [URI::HTTP, URI::HTTPS] AnkiConnect endpoint
    attr_reader :endpoint
    # @return [Numeric] Connection timeout in seconds
    attr_reader :open_timeout
    # @return [Numeric] Response timeout in seconds
    attr_reader :read_timeout
    # @return [Numeric] Request write timeout in seconds
    attr_reader :write_timeout

    # Creates a new AnkiConnect client.
    #
    # @param host [String] AnkiConnect server host (default: "127.0.0.1")
    # @param port [Integer] AnkiConnect server port (default: 8765)
    # @param endpoint [String, URI, nil] Complete HTTP or HTTPS endpoint; overrides host and port
    # @param api_key [String, nil] Optional API key for authentication
    # @param open_timeout [Numeric] Connection timeout in seconds
    # @param read_timeout [Numeric] Response timeout in seconds
    # @param write_timeout [Numeric] Request write timeout in seconds
    def initialize(
      host: '127.0.0.1', port: 8765, endpoint: nil, api_key: nil,
      open_timeout: 5, read_timeout: 60, write_timeout: 60
    )
      @endpoint = parse_endpoint(endpoint ? endpoint.to_s : "http://#{host}:#{port}")
      validate_endpoint!
      validate_api_key_transport!(api_key)
      @host = @endpoint.hostname
      @port = @endpoint.port
      @api_key = api_key
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @write_timeout = write_timeout
    end

    # Makes a request to the AnkiConnect API.
    # This is the core method used by all API operations.
    #
    # @param action [Symbol] The API action to perform
    # @param params [Hash] Parameters to send with the request
    # @return [Object] The result from the API
    # @raise [Error] If the API returns an error
    def request(action, **params)
      body = {
        action: action,
        version: API_VERSION,
        params: params
      }
      body[:key] = @api_key if @api_key

      response = perform_request(body.to_json, action)
      unless response.code.to_i.between?(200, 299)
        raise HTTPError.new(
          "AnkiConnect returned HTTP #{response.code}",
          action: action,
          status: response.code.to_i,
          body: response.body
        )
      end

      result = parse_response(response.body, action)

      raise APIError.new(result['error'].to_s, action: action) unless result['error'].nil?

      result['result']
    end

    private

    def perform_request(body, action)
      http = Net::HTTP.new(endpoint.hostname, endpoint.port)
      http.use_ssl = endpoint.scheme == 'https'
      http.open_timeout = open_timeout
      http.read_timeout = read_timeout
      http.write_timeout = write_timeout

      request = Net::HTTP::Post.new(endpoint.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = body

      http.start { |connection| connection.request(request) }
    rescue StandardError => e
      raise TransportError.new(e.message, action: action, original_error: e), cause: e
    end

    def parse_response(body, action)
      result = JSON.parse(body)
      unless result.is_a?(Hash) && result.key?('result') && result.key?('error')
        raise ProtocolError.new('AnkiConnect response must contain result and error', action: action, body: body)
      end

      result
    rescue JSON::ParserError => e
      raise ProtocolError.new('AnkiConnect returned invalid JSON', action: action, body: body), cause: e
    end

    def validate_endpoint!
      return if endpoint.is_a?(URI::HTTP) && endpoint.host

      raise ArgumentError, 'endpoint must be an HTTP or HTTPS URL with a host'
    end

    def validate_api_key_transport!(api_key)
      return if api_key.nil? || endpoint.scheme == 'https' || loopback_endpoint?

      raise ArgumentError, 'api_key requires HTTPS for non-loopback endpoints'
    end

    def loopback_endpoint?
      host = endpoint.hostname.downcase
      return true if host == 'localhost'

      IPAddr.new(host).loopback?
    rescue IPAddr::InvalidAddressError
      false
    end

    def parse_endpoint(value)
      URI(value)
    rescue URI::InvalidURIError => e
      raise ArgumentError, 'endpoint must be an HTTP or HTTPS URL with a host', cause: e
    end
  end

  # Base error for AnkiConnect request failures.
  class Error < StandardError
    attr_reader :action

    def initialize(message = nil, action: nil)
      @action = action
      super(message)
    end
  end

  # Error raised when the HTTP request cannot be completed.
  class TransportError < Error
    attr_reader :original_error

    def initialize(message = nil, original_error:, **context)
      @original_error = original_error
      super(message, **context)
    end
  end

  # Error raised for a non-successful HTTP response.
  class HTTPError < Error
    attr_reader :status, :body

    def initialize(message = nil, status:, body:, **context)
      @status = status
      @body = body
      super(message, **context)
    end
  end

  # Error raised when the response does not follow the AnkiConnect protocol.
  class ProtocolError < Error
    attr_reader :body

    def initialize(message = nil, body:, **context)
      @body = body
      super(message, **context)
    end
  end

  # Error returned by an AnkiConnect action.
  class APIError < Error; end
end
