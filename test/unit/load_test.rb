# frozen_string_literal: true

require_relative '../test_helper'

class LoadTest < Minitest::Test
  def test_client_composes_all_api_modules
    client = AnkiConnect::Client.new

    %i[
      deck_names add_note cards note_type_names store_media gui_browse cards_reviewed_today api_version
    ].each do |method|
      assert_respond_to client, method
    end
  end
end
