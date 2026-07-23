# frozen_string_literal: true

require_relative '../unit_test_helper'

class ClientTest < UnitTest
  Response = Struct.new(:code, :body)

  class FakeHTTP
    attr_accessor :host, :port, :use_ssl, :open_timeout, :read_timeout, :write_timeout
    attr_reader :last_request

    def initialize(response: nil, error: nil)
      @response = response
      @error = error
    end

    def start
      raise @error if @error

      yield self
    end

    def request(request)
      @last_request = request
      @response
    end
  end

  def test_default_endpoint
    client = AnkiConnect::Client.new

    assert_equal URI('http://127.0.0.1:8765'), client.endpoint
    assert_equal '127.0.0.1', client.host
    assert_equal 8765, client.port
  end

  def test_accepts_https_endpoint_uri
    client = AnkiConnect::Client.new(endpoint: URI('https://anki.example.test/connect'))
    http = request_with(client, response(result: 6)) { |instance| instance.api_version }

    assert http.use_ssl
    assert_equal 'anki.example.test', http.host
    assert_equal 443, http.port
    assert_equal '/connect', http.last_request.path
  end

  def test_connects_to_ipv6_hostname_without_brackets
    client = AnkiConnect::Client.new(endpoint: 'http://[::1]:8765')
    http = request_with(client, response(result: 6)) { |instance| instance.api_version }

    assert_equal '::1', client.host
    assert_equal '::1', http.host
    assert_equal 8765, http.port
  end

  def test_rejects_invalid_endpoint
    error = assert_raises(ArgumentError) do
      AnkiConnect::Client.new(endpoint: 'ftp://anki.example.test')
    end

    assert_equal 'endpoint must be an HTTP or HTTPS URL with a host', error.message
  end

  def test_rejects_malformed_endpoint
    error = assert_raises(ArgumentError) do
      AnkiConnect::Client.new(endpoint: 'bad url')
    end

    assert_equal 'endpoint must be an HTTP or HTTPS URL with a host', error.message
    assert_instance_of URI::InvalidURIError, error.cause
  end

  def test_serializes_request
    client = AnkiConnect::Client.new
    http = request_with(client, response(result: ['Default'])) { |instance| instance.deck_names }
    payload = JSON.parse(http.last_request.body)

    assert_equal 'application/json', http.last_request['Content-Type']
    assert_equal 'deckNames', payload['action']
    assert_equal AnkiConnect::API_VERSION, payload['version']
    assert_equal({}, payload['params'])
    refute payload.key?('key')
  end

  def test_serializes_api_key
    client = AnkiConnect::Client.new(api_key: 'secret')
    http = request_with(client, response(result: 6)) { |instance| instance.api_version }

    assert_equal 'secret', JSON.parse(http.last_request.body)['key']
  end

  def test_rejects_api_key_over_remote_plaintext_http
    error = assert_raises(ArgumentError) do
      AnkiConnect::Client.new(endpoint: 'http://anki.example.test', api_key: 'secret')
    end

    assert_equal 'api_key requires HTTPS for non-loopback endpoints', error.message
  end

  def test_does_not_treat_127_prefixed_hostname_as_loopback
    assert_raises(ArgumentError) do
      AnkiConnect::Client.new(endpoint: 'http://127.example.test', api_key: 'secret')
    end
  end

  def test_allows_api_key_over_ipv4_loopback_range
    client = AnkiConnect::Client.new(endpoint: 'http://127.0.0.2:8765', api_key: 'secret')
    http = request_with(client, response(result: 6)) { |instance| instance.api_version }

    assert_equal 'secret', JSON.parse(http.last_request.body)['key']
  end

  def test_allows_api_key_over_https
    client = AnkiConnect::Client.new(endpoint: 'https://anki.example.test', api_key: 'secret')
    http = request_with(client, response(result: 6)) { |instance| instance.api_version }

    assert_equal 'secret', JSON.parse(http.last_request.body)['key']
  end

  def test_configures_timeouts
    client = AnkiConnect::Client.new(open_timeout: 1, read_timeout: 2, write_timeout: 3)
    http = request_with(client, response(result: 6)) { |instance| instance.api_version }

    assert_equal 1, http.open_timeout
    assert_equal 2, http.read_timeout
    assert_equal 3, http.write_timeout
  end

  def test_returns_api_result
    client = AnkiConnect::Client.new
    result = nil

    request_with(client, response(result: %w[Default Archive])) do |instance|
      result = instance.deck_names
    end

    assert_equal %w[Default Archive], result
  end

  def test_raises_api_error
    client = AnkiConnect::Client.new

    error = assert_raises(AnkiConnect::APIError) do
      request_with(client, response(error: 'unsupported action')) { |instance| instance.api_version }
    end

    assert_kind_of AnkiConnect::Error, error
    assert_equal :version, error.action
    assert_equal 'unsupported action', error.message
  end

  def test_raises_http_error
    client = AnkiConnect::Client.new
    response = Response.new('503', 'temporarily unavailable')

    error = assert_raises(AnkiConnect::HTTPError) do
      request_with(client, response) { |instance| instance.api_version }
    end

    assert_equal 503, error.status
    assert_equal 'temporarily unavailable', error.body
    assert_equal :version, error.action
  end

  def test_raises_protocol_error_for_invalid_json
    client = AnkiConnect::Client.new

    error = assert_raises(AnkiConnect::ProtocolError) do
      request_with(client, Response.new('200', '<html>')) { |instance| instance.api_version }
    end

    assert_equal '<html>', error.body
    assert_equal :version, error.action
    assert_instance_of JSON::ParserError, error.cause
  end

  def test_raises_protocol_error_for_invalid_response_shape
    client = AnkiConnect::Client.new

    error = assert_raises(AnkiConnect::ProtocolError) do
      request_with(client, Response.new('200', '{}')) { |instance| instance.api_version }
    end

    assert_equal 'AnkiConnect response must contain result and error', error.message
  end

  def test_raises_transport_error
    client = AnkiConnect::Client.new
    original_error = Errno::ECONNREFUSED.new

    error = assert_raises(AnkiConnect::TransportError) do
      request_with(client, nil, error: original_error) { |instance| instance.api_version }
    end

    assert_same original_error, error.original_error
    assert_same original_error, error.cause
    assert_equal :version, error.action
  end

  private

  def request_with(client, response, error: nil)
    http = FakeHTTP.new(response: response, error: error)
    http_factory = lambda do |host, port|
      http.host = host
      http.port = port
      http
    end

    Net::HTTP.stub(:new, http_factory) { yield client }
    http
  end

  def response(result: nil, error: nil)
    Response.new('200', JSON.generate(result: result, error: error))
  end
end
