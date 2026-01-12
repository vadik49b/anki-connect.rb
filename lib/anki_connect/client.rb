# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module AnkiConnect
  # Main client class that includes all API modules and provides
  # the core request mechanism.
  class Client
    include AnkiConnect::Client::Cards
    include AnkiConnect::Client::Decks
    include AnkiConnect::Client::Models
    include AnkiConnect::Client::Notes
    include AnkiConnect::Client::Media
    include AnkiConnect::Client::Graphical
    include AnkiConnect::Client::Statistics
    include AnkiConnect::Client::Miscellaneous

    # @return [String] AnkiConnect server host
    attr_reader :host
    # @return [Integer] AnkiConnect server port
    attr_reader :port
    # @return [String, nil] API key for authentication (if configured)
    attr_reader :api_key

    # Creates a new AnkiConnect client.
    #
    # @param host [String] AnkiConnect server host (default: "127.0.0.1")
    # @param port [Integer] AnkiConnect server port (default: 8765)
    # @param api_key [String, nil] Optional API key for authentication
    def initialize(host: '127.0.0.1', port: 8765, api_key: nil)
      @host = host
      @port = port
      @api_key = api_key
      @uri = URI("http://#{host}:#{port}")
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

      response = Net::HTTP.post(
        @uri,
        body.to_json,
        'Content-Type' => 'application/json'
      )

      result = JSON.parse(response.body)

      raise Error, result['error'] if result['error']

      result['result']
    end

    private

    attr_reader :uri
  end

  # Error raised when the AnkiConnect API returns an error response.
  class Error < StandardError; end
end
