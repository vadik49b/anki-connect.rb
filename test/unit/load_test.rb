# frozen_string_literal: true

require_relative '../test_helper'

class LoadTest < Minitest::Test
  def test_client_is_available
    assert_kind_of Class, AnkiConnect::Client
  end
end
