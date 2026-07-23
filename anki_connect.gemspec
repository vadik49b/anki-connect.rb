# frozen_string_literal: true

require_relative 'lib/anki_connect/version'

Gem::Specification.new do |spec|
  spec.name = 'anki_connect'
  spec.version = AnkiConnect::VERSION
  spec.authors = ['vadik49b']
  spec.email = ['vadim@boltach.com']

  spec.summary = 'Ruby wrapper for the Anki-Connect HTTP API'
  spec.description = 'AnkiConnect provides a simple HTTP API to communicate with Anki. This Ruby gem is a wrapper around that API.'
  spec.homepage = 'https://github.com/vadik49b/anki-connect.rb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/main"
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/anki_connect'
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'examples/**/*.rb', 'CHANGELOG.md', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
end
