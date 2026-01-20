# AnkiConnect Ruby

[AnkiConnect provides a simple HTTP API](https://git.sr.ht/~foosoft/anki-connect) to communicate with Anki. This Ruby gem is a wrapper around that API.

## Installation

First, install the [AnkiConnect](https://ankiweb.net/shared/info/2055492159) addon in Anki:

1. Open Anki
2. Go to Tools → Add-ons (⇧⌘A on macOS)
3. Click "Get Add-ons..."
4. Enter the code `2055492159` and click OK
5. Restart Anki

Anki must be kept running in the background for other applications to use AnkiConnect. You can verify that AnkiConnect is running by visiting `localhost:8765` in your browser. If the server is running, you will see `{ "apiVersion": "AnkiConnect v.6" }`.

Then add this line to your application's Gemfile:

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

For a complete list of all API methods, see the [RubyDoc documentation](https://rubydoc.info/gems/anki_connect). More examples in the [`examples/`](examples/) directory.

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
