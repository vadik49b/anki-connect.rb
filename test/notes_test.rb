# frozen_string_literal: true

require_relative 'test_helper'

class NotesTest < Minitest::Test
  include IntegrationTestSetup

  def test_add_and_get_note
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'Hello', 'Back' => 'World' },
      tags: ['test-tag']
    )

    assert note_id.is_a?(Integer)

    notes = @client.get_notes(note_ids: [note_id])
    assert_equal 1, notes.size
    assert_equal 'Hello', notes.first['fields']['Front']['value']
  end

  def test_search_notes
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'SearchTest', 'Back' => 'FindMe' }
    )

    found_ids = @client.search_notes("deck:#{TEST_DECK}")
    assert_includes found_ids, note_id
  end

  def test_update_note
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'Original', 'Back' => 'Content' }
    )

    @client.update_note(note_id, fields: { 'Front' => 'Updated' })

    notes = @client.get_notes(note_ids: [note_id])
    assert_equal 'Updated', notes.first['fields']['Front']['value']
  end

  def test_add_and_remove_tags
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      model_name: TEST_MODEL,
      fields: { 'Front' => 'TagTest', 'Back' => 'Tags' },
      tags: ['initial-tag']
    )

    @client.add_tags([note_id], 'new-tag')
    tags = @client.get_note_tags(note_id)
    assert_includes tags, 'new-tag'

    @client.remove_tags([note_id], 'new-tag')
    tags = @client.get_note_tags(note_id)
    refute_includes tags, 'new-tag'
  end
end
