# frozen_string_literal: true

require_relative '../integration_test_helper'

class DecksTest < Minitest::Test
  include IntegrationTestSetup

  def test_deck_names
    names = @client.deck_names
    assert_includes names, @test_deck
  end

  def test_deck_names_and_ids
    names_and_ids = @client.deck_names_and_ids
    assert names_and_ids.key?(@test_deck)
    assert names_and_ids[@test_deck].is_a?(Integer)
    assert_equal @test_deck, @client.deck_name_from_id(names_and_ids[@test_deck])
  end

  def test_get_deck_config
    config = @client.deck_config(@test_deck)
    assert config.is_a?(Hash)
    assert config.key?('name')
  end

  def test_get_deck_stats
    stats = @client.deck_stats([@test_deck])
    assert stats.is_a?(Hash)
  end
end
