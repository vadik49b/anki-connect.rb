# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/recording_client'

class UnitTest < Minitest::Test
  private

  def assert_request(action, params = {}, results: [], &)
    client = RecordingClient.new(results: results)

    yield client

    assert_equal [[action, params]], client.requests
  end
end
