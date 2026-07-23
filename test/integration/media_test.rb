# frozen_string_literal: true

require_relative '../integration_test_helper'

class MediaTest < Minitest::Test
  def setup
    @client = AnkiConnect::Client.new
  end

  def test_store_and_retrieve_media
    filename = "_anki_connect_ruby_test_#{SecureRandom.hex(8)}.txt"
    encoded_content = 'QW5raUNvbm5lY3QgUnVieSBpbnRlZ3JhdGlvbiB0ZXN0'
    stored = false

    stored_filename = @client.store_media(filename, data: encoded_content)
    stored = true

    assert_equal filename, stored_filename
    assert_equal encoded_content, @client.retrieve_media(filename)
    assert_includes @client.media_files(pattern: filename), filename
    assert_kind_of String, @client.media_directory
  ensure
    if @client && filename
      @client.delete_media(filename)
      assert_equal false, @client.retrieve_media(filename) if stored
    end
  end
end
