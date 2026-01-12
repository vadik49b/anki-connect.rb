# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/anki_connect'

module IntegrationTestSetup
  TEST_DECK = '_AnkiConnectRubyTest'
  TEST_MODEL = 'Basic'

  def setup
    @client = AnkiConnect::Client.new
    @client.create_deck(TEST_DECK)
  end

  def teardown
    @client.delete_decks([TEST_DECK], cards_too: true)
  end
end
