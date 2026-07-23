#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Add ElevenLabs TTS audio to Anki cloze cards
#
# I use Anki to learn Spanish with cloze deletion cards for phrases.
# To train my ear for pronunciation, I want audio for each phrase.
# This script uses ElevenLabs TTS API to generate speech and attach it to cards.
#
# Configuration via environment variables:
#   ELEVENLABS_API_KEY - Your ElevenLabs API key
#   ELEVENLABS_VOICE_ID - Voice ID to use
#
# Usage:
# ELEVENLABS_API_KEY=your_key ELEVENLABS_VOICE_ID=voice_id ruby examples/add_elevenlabs_tts_audio_to_cloze_cards.rb

require 'net/http'
require 'json'
require 'uri'
require 'anki_connect'

ELEVENLABS_API_KEY = ENV.fetch('ELEVENLABS_API_KEY')
ELEVENLABS_VOICE_ID = ENV.fetch('ELEVENLABS_VOICE_ID')

if ELEVENLABS_API_KEY.strip.empty? || ELEVENLABS_VOICE_ID.strip.empty?
  raise 'ELEVENLABS_API_KEY and ELEVENLABS_VOICE_ID are required'
end

SPEECH_FOLDER = 'tmp'

client = AnkiConnect::Client.new
client.sync

# Customize this query for your deck and note type
notes = client.notes(query: 'deck:Spanish note:Cloze -tag:fix')
puts "Found #{notes.length} cloze note(s)"

Dir.mkdir(SPEECH_FOLDER) unless Dir.exist?(SPEECH_FOLDER)

notes.each_with_index do |note, index|
  print "\rProcessing #{index + 1}/#{notes.length}..."

  text_field = note.dig('fields', 'Text', 'value')
  next if text_field.nil? || text_field.strip.empty?

  back_extra = note.dig('fields', 'Back Extra', 'value') || ''
  already_has_audio = back_extra.include?('[sound:')
  next if already_has_audio

  # Extract full phrase from cloze markup: {{c1::answer::hint}} -> answer
  answer_text = text_field.gsub(/\{\{c\d+::([^:}]+)(?:::[^}]+)?\}\}/, '\1').gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip

  safe_text = answer_text.gsub(/[^a-zA-Z0-9]+/, '_').gsub(/^_+|_+$/, '')[0, 50]
  filename = "elevenlabs_#{note['noteId']}_#{safe_text}.mp3"
  filepath = File.expand_path(File.join(SPEECH_FOLDER, filename))

  unless File.exist?(filepath)
    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{ELEVENLABS_VOICE_ID}")
    request = Net::HTTP::Post.new(uri)
    request['Accept'] = 'audio/mpeg'
    request['xi-api-key'] = ELEVENLABS_API_KEY
    request['Content-Type'] = 'application/json'
    request.body = { text: answer_text, model_id: 'eleven_multilingual_v2', language_code: 'es' }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    raise "ElevenLabs API error: #{response.code} - #{response.body}" unless response.code == '200'

    File.binwrite(filepath, response.body)
  end

  client.store_media(filename, path: filepath)
  client.update_note(note['noteId'], fields: { 'Back Extra' => "#{back_extra}[sound:#{filename}]" })
end

puts "\nDone!"
