# frozen_string_literal: true

class RecordingClient < AnkiConnect::Client
  attr_reader :requests

  def initialize(results: [])
    super()
    @requests = []
    @results = results.dup
  end

  def request(action, **params)
    @requests << [action, params]
    @results.shift
  end
end
