# frozen_string_literal: true

require_relative '../integration_test_helper'

class NoteTypesTest < Minitest::Test
  def setup
    @client = AnkiConnect::Client.new
  end

  def test_note_type_name_from_id
    note_type_name, note_type_id = @client.note_type_names_and_ids.first

    assert_equal note_type_name, @client.note_type_name_from_id(note_type_id)
  end

  def test_read_only_note_type_details
    note_type_name, note_type_id = @client.note_type_names_and_ids.first

    assert_equal note_type_id, @client.note_types_by_id([note_type_id]).first.fetch('id')
    assert_equal note_type_name, @client.note_types_by_name([note_type_name]).first.fetch('name')
    assert_kind_of Array, @client.note_type_field_names(note_type_name)
    assert_kind_of Array, @client.note_type_field_descriptions(note_type_name)
    assert_kind_of Hash, @client.note_type_field_fonts(note_type_name)
    assert_kind_of Hash, @client.note_type_fields_on_templates(note_type_name)
    assert_kind_of Hash, @client.note_type_templates(note_type_name)
    assert_kind_of Hash, @client.note_type_styling(note_type_name)
  end
end
