#!/usr/bin/env ruby
# frozen_string_literal: true

require 'anki_connect'

# Create a client
client = AnkiConnect::Client.new

# Get all decks
puts 'Available decks:'
client.deck_names.each { |deck| puts "  - #{deck}" }

# Get all models
puts "\nAvailable models:"
client.model_names.each { |model| puts "  - #{model}" }

# Add a new note
note_id = client.add_note(
  deck_name: 'Default',
  model_name: 'Basic',
  fields: { Front: 'What is the capital of France?', Back: 'Paris' },
  tags: %w[geography europe]
)

puts "\nCreated note with ID: #{note_id}"

# Find the note we just created
note_ids = client.search_notes('tag:geography')
puts "\nFound #{note_ids.length} notes with tag 'geography'"

# Get detailed info about the notes
notes = client.get_notes(note_ids: note_ids)
notes.each do |note|
  puts "\nNote #{note['noteId']}:"
  puts "  Model: #{note['modelName']}"
  puts "  Tags: #{note['tags'].join(', ')}"
  note['fields'].each do |field_name, field_data|
    puts "  #{field_name}: #{field_data['value']}"
  end
end

# Get statistics
reviewed_today = client.cards_reviewed_today
puts "\nCards reviewed today: #{reviewed_today}"

# Clean up - delete the note we created
client.delete_notes([note_id])
puts "\nDeleted note #{note_id}"
