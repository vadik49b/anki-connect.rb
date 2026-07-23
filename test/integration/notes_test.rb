# frozen_string_literal: true

require_relative '../integration_test_helper'

class NotesTest < Minitest::Test
  include IntegrationTestSetup

  def test_add_and_get_note
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      note_type_name: TEST_NOTE_TYPE,
      fields: { 'Front' => 'Hello', 'Back' => 'World' },
      tags: ['test-tag']
    )

    assert note_id.is_a?(Integer)

    notes = @client.notes(note_ids: [note_id])
    assert_equal 1, notes.size
    assert_equal 'Hello', notes.first['fields']['Front']['value']
  end

  def test_search_notes
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      note_type_name: TEST_NOTE_TYPE,
      fields: { 'Front' => 'SearchTest', 'Back' => 'FindMe' }
    )

    found_ids = @client.search_notes("deck:#{TEST_DECK}")
    assert_includes found_ids, note_id
  end

  def test_note_addability
    note = {
      deck_name: TEST_DECK,
      note_type_name: TEST_NOTE_TYPE,
      fields: { 'Front' => 'Addable', 'Back' => 'Test' }
    }

    assert @client.note_addable?(note)
    assert_equal [true], @client.note_addability_statuses([note])
  end

  def test_update_note
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      note_type_name: TEST_NOTE_TYPE,
      fields: { 'Front' => 'Original', 'Back' => 'Content' }
    )

    @client.update_note(note_id, fields: { 'Front' => 'Updated' })

    notes = @client.notes(note_ids: [note_id])
    assert_equal 'Updated', notes.first['fields']['Front']['value']
  end

  def test_direct_note_updates
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      note_type_name: TEST_NOTE_TYPE,
      fields: { 'Front' => 'Original', 'Back' => 'Content' }
    )

    @client.update_note_fields(note_id, fields: { 'Front' => 'Updated directly' })
    @client.update_note_tags(note_id, ['direct-update'])

    note = @client.notes(note_ids: [note_id]).first
    assert_equal 'Updated directly', note['fields']['Front']['value']
    assert_equal ['direct-update'], note['tags']
  end

  def test_add_and_remove_tags
    note_id = @client.add_note(
      deck_name: TEST_DECK,
      note_type_name: TEST_NOTE_TYPE,
      fields: { 'Front' => 'TagTest', 'Back' => 'Tags' },
      tags: ['initial-tag']
    )

    @client.add_tags([note_id], 'new-tag')
    tags = @client.note_tags(note_id)
    assert_includes tags, 'new-tag'

    @client.remove_tags([note_id], 'new-tag')
    tags = @client.note_tags(note_id)
    refute_includes tags, 'new-tag'
  end
end
