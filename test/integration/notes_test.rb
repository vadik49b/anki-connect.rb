# frozen_string_literal: true

require_relative '../integration_test_helper'

class NotesTest < Minitest::Test
  include IntegrationTestSetup

  def test_add_and_get_note
    input = test_note('Hello', tags: ['test-tag'])
    note_id = @client.add_note(**input)

    assert note_id.is_a?(Integer)

    notes = @client.notes(note_ids: [note_id])
    assert_equal 1, notes.size
    assert_equal input[:fields][first_field(input)], notes.first['fields'][first_field(input)]['value']
  end

  def test_search_notes
    note_id = @client.add_note(**test_note('SearchTest'))

    found_ids = @client.search_notes("deck:#{@test_deck}")
    assert_includes found_ids, note_id
  end

  def test_note_addability
    note = test_note('Addable')

    assert @client.note_addable?(note)
    assert_equal [true], @client.note_addability_statuses([note])
  end

  def test_update_note
    input = test_note('Original')
    field = first_field(input)
    note_id = @client.add_note(**input)

    @client.update_note(note_id, fields: { field => 'Updated' })

    notes = @client.notes(note_ids: [note_id])
    assert_equal 'Updated', notes.first['fields'][field]['value']
  end

  def test_direct_note_updates
    input = test_note('Original')
    field = first_field(input)
    note_id = @client.add_note(**input)

    @client.update_note_fields(note_id, fields: { field => 'Updated directly' })
    @client.update_note_tags(note_id, ['direct-update'])

    note = @client.notes(note_ids: [note_id]).first
    assert_equal 'Updated directly', note['fields'][field]['value']
    assert_equal ['direct-update'], note['tags']
  end

  def test_add_and_remove_tags
    note_id = @client.add_note(**test_note('TagTest', tags: ['initial-tag']))

    @client.add_tags([note_id], 'new-tag')
    tags = @client.note_tags(note_id)
    assert_includes tags, 'new-tag'

    @client.remove_tags([note_id], 'new-tag')
    tags = @client.note_tags(note_id)
    refute_includes tags, 'new-tag'
  end
end
