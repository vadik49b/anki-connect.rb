#!/usr/bin/env ruby
# frozen_string_literal: true

require 'anki_connect'

client = AnkiConnect::Client.new

puts 'Available decks:'
client.deck_names.each { |deck| puts "  - #{deck}" }

puts "\nAvailable note types:"
client.note_type_names.each { |note_type| puts "  - #{note_type}" }

note_id = client.add_note(
  deck_name: 'Default',
  note_type_name: 'Basic',
  fields: { Front: 'What is the capital of France?', Back: 'Paris' },
  tags: %w[geography europe]
)

puts "\nCreated note with ID: #{note_id}"

note_ids = client.search_notes('tag:geography')
puts "\nFound #{note_ids.length} notes with tag 'geography'"

notes = client.notes(note_ids: note_ids)
notes.each do |note|
  puts "\nNote #{note['noteId']}:"
  puts "  Note type: #{note['modelName']}"
  puts "  Tags: #{note['tags'].join(', ')}"
  note['fields'].each do |field_name, field_data|
    puts "  #{field_name}: #{field_data['value']}"
  end
end

reviewed_today = client.cards_reviewed_today
puts "\nCards reviewed today: #{reviewed_today}"

client.delete_notes([note_id])
puts "\nDeleted note #{note_id}"
