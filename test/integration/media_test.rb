# frozen_string_literal: true

require_relative '../integration_test_helper'

class MediaTest < Minitest::Test
  def setup
    @client = AnkiConnect::Client.new
  end

  def test_store_and_retrieve_media
    filename = "_anki_connect_ruby_test_#{SecureRandom.hex(8)}.txt"
    encoded_content = 'QW5raUNvbm5lY3QgUnVieSBpbnRlZ3JhdGlvbiB0ZXN0'
    stored_filename = nil

    stored_filename = @client.store_media(filename, data: encoded_content)

    assert_equal filename, stored_filename
    assert_equal encoded_content, @client.retrieve_media(filename)
  ensure
    @client&.delete_media(stored_filename) if stored_filename
  end
end
