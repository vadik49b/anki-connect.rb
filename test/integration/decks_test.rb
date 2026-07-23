# frozen_string_literal: true

require_relative '../integration_test_helper'

class DecksTest < Minitest::Test
  include IntegrationTestSetup

  def test_deck_names
    names = @client.deck_names
    assert_includes names, TEST_DECK
  end

  def test_deck_names_and_ids
    names_and_ids = @client.deck_names_and_ids
    assert names_and_ids.key?(TEST_DECK)
    assert names_and_ids[TEST_DECK].is_a?(Integer)
    assert_equal TEST_DECK, @client.deck_name_from_id(names_and_ids[TEST_DECK])
  end

  def test_get_deck_config
    config = @client.deck_config(TEST_DECK)
    assert config.is_a?(Hash)
    assert config.key?('name')
  end

  def test_get_deck_stats
    stats = @client.deck_stats([TEST_DECK])
    assert stats.is_a?(Hash)
  end
end
