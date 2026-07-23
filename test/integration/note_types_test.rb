# frozen_string_literal: true

require_relative '../integration_test_helper'

class NoteTypesTest < Minitest::Test
  TEST_NOTE_TYPE = 'Basic'

  def setup
    @client = AnkiConnect::Client.new
  end

  def test_note_type_name_from_id
    note_type_id = @client.note_type_names_and_ids.fetch(TEST_NOTE_TYPE)

    assert_equal TEST_NOTE_TYPE, @client.note_type_name_from_id(note_type_id)
  end
end
