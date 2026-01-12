# frozen_string_literal: true

require_relative 'anki_connect/version'
require_relative 'anki_connect/cards'
require_relative 'anki_connect/decks'
require_relative 'anki_connect/models'
require_relative 'anki_connect/notes'
require_relative 'anki_connect/media'
require_relative 'anki_connect/graphical'
require_relative 'anki_connect/statistics'
require_relative 'anki_connect/miscellaneous'
require_relative 'anki_connect/client'

# Ruby client for AnkiConnect, enabling external applications to interact
# with Anki through HTTP.
#
# @example Basic usage
#   client = AnkiConnect::Client.new
#   decks = client.deck_names
#   cards = client.search_cards("deck:Default")
#
# @see https://foosoft.net/projects/anki-connect/ AnkiConnect Documentation
module AnkiConnect
end
