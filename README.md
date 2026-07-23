# AnkiConnect Ruby

An idiomatic Ruby client for the [AnkiConnect](https://git.sr.ht/~foosoft/anki-connect) HTTP API.

## Requirements

- Ruby 3.4 or newer
- Anki 23.10 or newer
- The [AnkiConnect add-on](https://ankiweb.net/shared/info/2055492159) (`2055492159`)

Install the add-on, restart Anki, and keep Anki running while using the gem. A working local AnkiConnect instance responds at [http://127.0.0.1:8765](http://127.0.0.1:8765).

## Installation

Add the gem to your `Gemfile`:

```ruby
gem 'anki_connect'
```

Then run `bundle install`, or install it directly with `gem install anki_connect`.

## Usage

```ruby
require 'anki_connect'

client = AnkiConnect::Client.new
note_id = client.add_note(
  deck_name: 'Default',
  note_type_name: 'Basic',
  fields: { Front: 'What is Ruby?', Back: 'A programming language' },
  tags: ['programming']
)

notes = client.notes(note_ids: [note_id])
# => [{ "noteId" => 1234567890,
#       "modelName" => "Basic",
#       "tags" => ["programming"],
#       "fields" => { "Front" => { "value" => "What is Ruby?", "order" => 0 },
#                     "Back" => { "value" => "A programming language", "order" => 1 } } }]
```

Wrapper inputs use snake_case and current Anki terminology. Response hashes preserve AnkiConnect's wire keys.

See [`examples/basic_usage.rb`](examples/basic_usage.rb) for a broader walkthrough and [`examples/`](examples/) for practical scripts. The complete API is documented on [RubyDoc](https://rubydoc.info/gems/anki_connect).

## Configuration

The client connects to `http://127.0.0.1:8765` by default. `AnkiConnect::Client.new` also accepts `endpoint:`, `api_key:`, and network timeout options. API keys may use plain HTTP only on loopback endpoints; remote authenticated endpoints must use HTTPS.

The low-level `request` method is available for actions outside the convenience API.

## Compatibility

Version 0.2 targets AnkiConnect API version 6 and was verified against official commit [`de6e6e1`](https://git.sr.ht/~foosoft/anki-connect/commit/de6e6e1b8aaf4ae195eb1d1ff6db5409b99b2a3e). See the [changelog](CHANGELOG.md) for breaking changes and the compact 0.1-to-0.2 rename map.

## Development

```bash
bundle install
bundle exec rake console
```

## Testing

Unit tests do not require Anki:

```bash
bundle exec rake test:unit
```

Run `bundle exec rake test:integration` for live tests. They modify the active Anki collection, so use a disposable profile when possible.

## Acknowledgments

- [Anki-Connect](https://git.sr.ht/~foosoft/anki-connect) by FooSoft for the excellent Anki plugin
- [Anki](https://apps.ankiweb.net/) for the amazing spaced repetition software
