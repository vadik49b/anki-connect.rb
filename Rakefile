# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

namespace :test do
  task :integration_warning do
    warn 'WARNING: integration tests modify the collection in the active Anki profile.'
  end

  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/unit/**/*_test.rb']
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/integration/**/*_test.rb']
  end

  Rake::Task['test:integration'].enhance(['test:integration_warning'])
end

desc 'Run unit tests'
task test: 'test:unit'

desc 'Run integration tests against the active Anki profile (modifies the collection)'
task integration: 'test:integration'

task default: 'test:unit'

desc 'Run RuboCop'
task :rubocop do
  sh 'bundle exec rubocop -A'
end

desc 'Open IRB console with the gem loaded'
task :console do
  require 'irb'
  require_relative 'lib/anki_connect'
  ARGV.clear
  IRB.start
end
