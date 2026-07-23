# frozen_string_literal: true

require_relative '../integration_test_helper'

class CardsTest < Minitest::Test
  include IntegrationTestSetup

  def test_search_and_get_cards
    @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'CardTest', 'Back' => 'Cards' }
    )

    card_ids = @client.search_cards("deck:#{TEST_DECK}")
    assert card_ids.any?

    cards = @client.get_cards(card_ids)
    assert_equal card_ids.size, cards.size
  end

  def test_get_note_ids
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'NoteIdTest', 'Back' => 'Test' }
    )

    card_ids = @client.search_cards("deck:#{TEST_DECK}")
    note_ids = @client.get_note_ids(card_ids)

    assert_includes note_ids, note_id
  end

  def test_suspend_and_unsuspend
    @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'SuspendTest', 'Back' => 'Test' }
    )

    card_ids = @client.search_cards("deck:#{TEST_DECK}")

    @client.suspend_cards(card_ids)
    assert @client.suspended?(card_ids.first)

    @client.unsuspend_cards(card_ids)
    refute @client.suspended?(card_ids.first)
  end
end
