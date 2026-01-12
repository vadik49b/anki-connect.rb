# AnkiConnect Ruby

[AnkiConnect](https://git.sr.ht/~foosoft/anki-connect) provides a simple HTTP API to communicate with Anki. This Ruby gem is a wrapper around that API.

## Requirements

- Ruby 3.4+
- Anki with Anki-Connect plugin installed

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anki_connect'
```

Or install it yourself:

```bash
gem install anki_connect
```

## Usage

```ruby
require 'anki_connect'

# Create a client (default: localhost:8765)
client = AnkiConnect::Client.new

# Get all decks
decks = client.deck_names

# Add a new note
note_id = client.add_note(
  deck_name: "Default",
  model_name: "Basic",
  fields: { Front: "What is Ruby?", Back: "A programming language" },
  tags: ["programming"]
)

# Get note details
notes = client.get_notes(query: "deck:Default")
# => [{ "noteId" => 1234567890,
#       "modelName" => "Basic",
#       "tags" => ["programming"],
#       "fields" => { "Front" => { "value" => "What is Ruby?", "order" => 0 },
#                     "Back" => { "value" => "A programming language", "order" => 1 } } }]
```

For more examples, see the [`examples/`](examples/) directory.

## Development

```bash
# Install dependencies
bundle install

# Open console with gem loaded
bundle exec rake console
```

## Acknowledgments

- [Anki-Connect](https://git.sr.ht/~foosoft/anki-connect) by FooSoft for the excellent Anki plugin
- [Anki](https://apps.ankiweb.net/) for the amazing spaced repetition software
