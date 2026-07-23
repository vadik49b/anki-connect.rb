# frozen_string_literal: true

require_relative '../integration_test_helper'

class MiscTest < Minitest::Test
  def setup
    @client = AnkiConnect::Client.new
  end

  def test_version
    version = @client.api_version
    assert version.is_a?(Integer)
    assert version >= 6
  end

  def test_profiles
    profiles = @client.profiles
    assert profiles.is_a?(Array)
    assert profiles.any?
  end

  def test_active_profile
    profile = @client.active_profile
    assert profile.is_a?(String)
  end
end
