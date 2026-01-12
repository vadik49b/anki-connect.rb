# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

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
