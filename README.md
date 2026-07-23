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
  note_type_name: "Basic",
  fields: { Front: "What is Ruby?", Back: "A programming language" },
  tags: ["programming"]
)

# Get note details
notes = client.notes(query: "deck:Default")
# => [{ "noteId" => 1234567890,
#       "modelName" => "Basic",
#       "tags" => ["programming"],
#       "fields" => { "Front" => { "value" => "What is Ruby?", "order" => 0 },
#                     "Back" => { "value" => "A programming language", "order" => 1 } } }]
```

Convenience wrapper inputs use snake_case and current Anki terminology such as `note_type_name`. Response hashes, raw `request` and `batch` payloads, deck configuration round-trips, field names, and action names preserve AnkiConnect's wire keys, including `"modelName"`.

`batch` is a low-level escape hatch: each element must be a raw AnkiConnect action envelope with `action`, `version`, and wire-format `params`. Prefer the named wrappers, or `request` for a single action.

### Compatibility

This release targets AnkiConnect API version 6 and was verified against official AnkiConnect commit [`de6e6e1`](https://git.sr.ht/~foosoft/anki-connect/commit/de6e6e1b8aaf4ae195eb1d1ff6db5409b99b2a3e). That commit is newer than release `25.11.9.0`; `gui_add_note_set_data` requires this post-release revision or newer. The tested upstream version requires Anki 23.10 or newer.

The low-level `request` method remains available for actions added after this tested upstream revision.

### Enumerable Statuses

Scalar predicates return one Boolean. Methods that query multiple cards return arrays in input order so they compose with Ruby's `Enumerable` API:

```ruby
statuses = client.card_suspension_statuses(card_ids)

statuses.all?          # every card is suspended
statuses.any?          # at least one card is suspended
statuses.none?         # no cards are suspended
statuses.count(true)   # number of suspended cards
```

Suspension statuses contain `nil` when a card does not exist. Use `compact` or an explicit comparison when missing cards need different handling.

### Upgrading From 0.1

Version 0.2 is a clean API redesign and does not provide compatibility aliases. Important changes include:

- Convenience wrapper inputs use snake_case throughout, including nested note options, media, templates, answers, and GUI options.
- Public “model” terminology is replaced by Anki's current “note type” terminology.
- Mechanical `get_*` names are replaced by resource names such as `notes`, `cards`, `deck_config`, and `reviews`.
- Scalar card predicates and positional status arrays are separate methods.
- `version` is now `api_version`; the gem version remains `AnkiConnect::VERSION`.
- `multi` is now `batch`, `api_reflect` is now `api_capabilities`, and `import_deck` is now `import_package`.
- The misleading `remove_empty_notes` name is now `remove_unused_note_types`, matching its actual upstream behavior.

### Client Configuration

The client connects to `http://127.0.0.1:8765` by default. A complete endpoint URL, API key, and network timeouts can be configured when needed:

```ruby
client = AnkiConnect::Client.new(
  endpoint: "https://anki.example.com/connect",
  api_key: ENV.fetch("ANKI_CONNECT_API_KEY"),
  open_timeout: 5,
  read_timeout: 60,
  write_timeout: 60
)
```

The existing `host:` and `port:` options remain available for HTTP endpoints.
API keys are allowed over plaintext HTTP only for loopback endpoints; authenticated remote endpoints must use HTTPS. The configured API key is intentionally not exposed through a public reader.

### Errors

All client errors inherit from `AnkiConnect::Error`:

- `AnkiConnect::TransportError` indicates that the HTTP request could not be completed.
- `AnkiConnect::HTTPError` indicates a non-successful HTTP response and exposes `status` and `body`.
- `AnkiConnect::ProtocolError` indicates invalid JSON or a response missing the required `result` and `error` fields.
- `AnkiConnect::APIError` contains an error returned by an AnkiConnect action.

Errors expose the failed `action`. `TransportError` also exposes the underlying exception as `original_error`.

For a complete list of all API methods, see the [RubyDoc documentation](https://rubydoc.info/gems/anki_connect). More examples in the [`examples/`](examples/) directory.

## Development

```bash
# Install dependencies
bundle install

# Open console with gem loaded
bundle exec rake console
```

### Testing

Run the unit tests, which do not require Anki:

```bash
bundle exec rake
# or explicitly
bundle exec rake test:unit
```

Run the integration tests against a running AnkiConnect instance:

```bash
bundle exec rake test:integration
```

Integration tests modify the collection in the active Anki profile. They use a uniquely named temporary deck and only remove the deck when its creation succeeds, but a disposable profile is recommended.

## Acknowledgments

- [Anki-Connect](https://git.sr.ht/~foosoft/anki-connect) by FooSoft for the excellent Anki plugin
- [Anki](https://apps.ankiweb.net/) for the amazing spaced repetition software
