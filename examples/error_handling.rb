#!/usr/bin/env ruby
# frozen_string_literal: true

require 'anki_connect'

client = AnkiConnect::Client.new

begin
  puts client.deck_names
rescue AnkiConnect::TransportError => e
  warn "Could not reach AnkiConnect for #{e.action}: #{e.original_error.message}"
rescue AnkiConnect::HTTPError => e
  warn "AnkiConnect returned HTTP #{e.status} for #{e.action}: #{e.body}"
rescue AnkiConnect::ProtocolError => e
  warn "Invalid AnkiConnect response for #{e.action}: #{e.body}"
rescue AnkiConnect::APIError => e
  warn "AnkiConnect rejected #{e.action}: #{e.message}"
end
