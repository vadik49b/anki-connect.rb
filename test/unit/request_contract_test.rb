# frozen_string_literal: true

require_relative '../unit_test_helper'

class RequestContractTest < UnitTest
  def test_action_without_parameters
    assert_request(:deckNames, &:deck_names)
  end

  def test_deck_parameters
    assert_request(:changeDeck, { cards: [1, 2], deck: 'Archive' }) do |client|
      client.move_cards([1, 2], to: 'Archive')
    end
  end

  def test_scalar_card_predicate
    assert_request(:suspended, { card: 1 }) do |client|
      client.suspended?(1)
    end
  end

  def test_array_card_predicate
    assert_request(:areSuspended, { cards: [1, 2] }) do |client|
      client.suspended?([1, 2])
    end
  end

  def test_scalar_due_result
    assert_request(:areDue, { cards: [1] }, results: [[true]]) do |client|
      assert client.due?(1)
    end
  end

  def test_add_note_parameters
    assert_request(
      :addNote,
      {
        note: {
          deckName: 'Default',
          modelName: 'Basic',
          fields: { 'Front' => 'Question', 'Back' => 'Answer' },
          tags: ['ruby'],
          options: { allowDuplicate: true }
        }
      }
    ) do |client|
      client.add_note(
        deck_name: 'Default',
        model_name: 'Basic',
        fields: { 'Front' => 'Question', 'Back' => 'Answer' },
        tags: ['ruby'],
        options: { allowDuplicate: true }
      )
    end
  end

  def test_note_query_parameters
    assert_request(:notesInfo, { query: 'deck:Default' }) do |client|
      client.get_notes(query: 'deck:Default')
    end
  end

  def test_model_parameters
    assert_request(
      :createModel,
      {
        modelName: 'Basic 2',
        inOrderFields: %w[Front Back],
        cardTemplates: [{ 'Name' => 'Card 1', 'Front' => '{{Front}}', 'Back' => '{{Back}}' }],
        isCloze: false
      }
    ) do |client|
      client.create_model(
        name: 'Basic 2',
        fields: %w[Front Back],
        templates: [{ 'Name' => 'Card 1', 'Front' => '{{Front}}', 'Back' => '{{Back}}' }]
      )
    end
  end

  def test_media_parameters
    assert_request(
      :storeMediaFile,
      { filename: 'image.png', deleteExisting: false, path: '/tmp/image.png' }
    ) do |client|
      client.store_media('image.png', path: '/tmp/image.png', overwrite: false)
    end
  end

  def test_graphical_parameters
    assert_request(
      :guiBrowse,
      { query: 'deck:Default', reorderCards: { order: 'ascending', columnId: 'noteCrt' } }
    ) do |client|
      client.gui_browse('deck:Default', reorder_cards: { order: 'ascending', columnId: 'noteCrt' })
    end
  end

  def test_statistics_parameters
    assert_request(:cardReviews, { deck: 'Default', startID: 1_700_000_000_000 }) do |client|
      client.get_reviews('Default', after: 1_700_000_000_000)
    end
  end

  def test_miscellaneous_parameters
    assert_request(
      :exportPackage,
      { deck: 'Default', path: '/tmp/default.apkg', includeSched: true }
    ) do |client|
      client.export_deck('Default', '/tmp/default.apkg', include_scheduling: true)
    end
  end
end
