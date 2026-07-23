# frozen_string_literal: true

require 'securerandom'
require_relative 'test_helper'

module IntegrationTestSetup
  def setup
    @client = AnkiConnect::Client.new
    @test_deck = "_AnkiConnectRubyTest-#{Process.pid}-#{SecureRandom.hex(6)}"
    raise "integration test deck already exists: #{@test_deck}" if @client.deck_names.include?(@test_deck)

    @client.create_deck(@test_deck)
  end

  def teardown
    return unless @client && @test_deck

    @client.delete_decks([@test_deck], cards_too: true) if @client.deck_names.include?(@test_deck)
  end

  private

  def test_note(label, tags: [])
    note_type = test_note_type
    value = "#{label}-#{SecureRandom.hex(8)}"
    fields = note_type.fetch('flds').to_h { |field| [field.fetch('name'), value] }
    fields[fields.keys.first] = "{{c1::#{value}}}" if note_type.fetch('type').positive?

    {
      deck_name: @test_deck,
      note_type_name: note_type.fetch('name'),
      fields: fields,
      tags: tags
    }
  end

  def test_note_type
    @test_note_type ||= begin
      note_types = @client.note_types_by_name(@client.note_type_names)
      note_types.find { |note_type| note_type.fetch('flds').any? } ||
        raise('integration tests require a note type with at least one field')
    end
  end

  def first_field(note)
    note.fetch(:fields).keys.first
  end
end
