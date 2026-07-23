# frozen_string_literal: true

require 'securerandom'
require_relative 'test_helper'

module IntegrationTestSetup
  TEST_DECK = "_AnkiConnectRubyTest-#{Process.pid}-#{SecureRandom.hex(6)}"
  TEST_NOTE_TYPE = 'Basic'

  def setup
    @client = AnkiConnect::Client.new
    raise "integration test deck already exists: #{TEST_DECK}" if @client.deck_names.include?(TEST_DECK)

    @client.create_deck(TEST_DECK)
    @test_deck_created = true
  end

  def teardown
    return unless @test_deck_created

    @client.delete_decks([TEST_DECK], cards_too: true)
  end
end
