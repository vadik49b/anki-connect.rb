# frozen_string_literal: true

require_relative '../integration_test_helper'

class CardsTest < Minitest::Test
  include IntegrationTestSetup

  def test_search_and_get_cards
    @client.add_note(**test_note('CardTest'))

    card_ids = @client.search_cards("deck:#{@test_deck}")
    assert card_ids.any?

    cards = @client.cards(card_ids)
    assert_equal card_ids.size, cards.size
  end

  def test_note_ids_for_cards
    note_id = @client.add_note(**test_note('NoteIdTest'))

    card_ids = @client.search_cards("deck:#{@test_deck}")
    note_ids = @client.note_ids_for_cards(card_ids)

    assert_includes note_ids, note_id
  end

  def test_suspend_and_unsuspend
    note_id = @client.add_note(**test_note('SuspendTest'))

    card_ids = @client.notes(note_ids: [note_id]).first.fetch('cards')

    @client.suspend_cards(card_ids)
    assert @client.card_suspended?(card_ids.first)

    @client.unsuspend_cards(card_ids)
    refute @client.card_suspended?(card_ids.first)
  end
end
