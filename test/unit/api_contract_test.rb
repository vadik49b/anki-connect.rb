# frozen_string_literal: true

require_relative '../unit_test_helper'

class APIContractTest < UnitTest
  NOTE = {
    deck_name: 'Default',
    note_type_name: 'Basic',
    fields: { 'Front' => 'Question', 'Back' => 'Answer' }
  }.freeze

  def test_bulk_notes_normalize_nested_options_and_media
    note = NOTE.merge(
      options: {
        allow_duplicate: true,
        duplicate_scope: 'deck',
        duplicate_scope_options: { deck_name: 'Default', check_children: true, check_all_note_types: false }
      },
      media: {
        audio: [{ filename: 'word.mp3', fields: ['Front'], skip_hash: 'abc', overwrite: false }]
      }
    )
    expected_note = {
      deckName: 'Default',
      modelName: 'Basic',
      fields: NOTE[:fields],
      options: {
        allowDuplicate: true,
        duplicateScope: 'deck',
        duplicateScopeOptions: { deckName: 'Default', checkChildren: true, checkAllModels: false }
      },
      audio: [{ filename: 'word.mp3', fields: ['Front'], skipHash: 'abc', deleteExisting: false }]
    }

    assert_request(:addNotes, { notes: [expected_note] }) { |client| client.add_notes([note]) }
  end

  def test_direct_note_media_normalizes_nested_keys
    note = NOTE.merge(audio: [{ filename: 'word.mp3', fields: ['Front'], skip_hash: 'abc' }])
    expected = normalized_note.merge(
      audio: [{ filename: 'word.mp3', fields: ['Front'], skipHash: 'abc' }]
    )

    assert_request(:addNotes, { notes: [expected] }) { |client| client.add_notes([note]) }
  end

  def test_note_addability_actions
    assert_request(:canAddNote, { note: normalized_note }) { |client| client.note_addable?(NOTE) }
    assert_request(:canAddNoteWithErrorDetail, { note: normalized_note }) { |client| client.note_addability(NOTE) }
    assert_request(:canAddNotes, { notes: [normalized_note] }) do |client|
      client.note_addability_statuses([NOTE])
    end
    assert_request(:canAddNotesWithErrorDetail, { notes: [normalized_note] }) do |client|
      client.note_addability_details([NOTE])
    end
  end

  def test_media_only_note_update_uses_fields_path
    media = { picture: { filename: 'image.png', fields: ['Back'], path: '/tmp/image.png' } }
    expected = {
      id: 1,
      fields: {},
      picture: { filename: 'image.png', fields: ['Back'], path: '/tmp/image.png' }
    }

    assert_request(:updateNote, { note: expected }) { |client| client.update_note(1, media: media) }
  end

  def test_direct_note_update_actions
    assert_request(:updateNoteFields, { note: { id: 1, fields: { 'Front' => 'Updated' } } }) do |client|
      client.update_note_fields(1, fields: { 'Front' => 'Updated' })
    end
    assert_request(:updateNoteTags, { note: 1, tags: ['ruby'] }) do |client|
      client.update_note_tags(1, 'ruby')
    end
  end

  def test_update_note_requires_a_change
    client = RecordingClient.new

    error = assert_raises(ArgumentError) { client.update_note(1) }

    assert_equal 'provide fields, tags, or media to update', error.message
    assert_empty client.requests
  end

  def test_tag_arrays_become_anki_tag_queries
    assert_request(:addTags, { notes: [1], tags: 'ruby test' }) do |client|
      client.add_tags([1], %w[ruby test])
    end
  end

  def test_replace_tag_selects_the_matching_wire_action
    assert_request(
      :replaceTags,
      { notes: [1, 2], tag_to_replace: 'old', replace_with_tag: 'new' }
    ) do |client|
      client.replace_tag(from: 'old', to: 'new', note_ids: [1, 2])
    end
    assert_request(:replaceTagsInAllNotes, { tag_to_replace: 'old', replace_with_tag: 'new' }) do |client|
      client.replace_tag(from: 'old', to: 'new')
    end
  end

  def test_notes_requires_exactly_one_selector
    client = RecordingClient.new

    assert_raises(ArgumentError) { client.notes }
    assert_raises(ArgumentError) { client.notes(note_ids: [1], query: 'deck:Default') }
    assert_empty client.requests
  end

  def test_note_rejects_unknown_input_keys
    client = RecordingClient.new

    error = assert_raises(ArgumentError) { client.add_notes([NOTE.merge(unexpected: true)]) }

    assert_equal 'unknown note key: unexpected', error.message
    assert_empty client.requests
  end

  def test_note_rejects_duplicate_media_keys
    client = RecordingClient.new
    media_item = { filename: 'word.mp3', fields: ['Front'], data: 'eA==' }
    note = NOTE.merge(media: { audio: media_item }, audio: media_item)

    error = assert_raises(ArgumentError) { client.add_notes([note]) }

    assert_equal 'duplicate media key: audio', error.message
    assert_empty client.requests
  end

  def test_store_media_supports_skip_hash
    params = { filename: 'image.png', deleteExisting: true, path: '/tmp/image.png', skipHash: 'abc' }

    assert_request(:storeMediaFile, params) do |client|
      client.store_media('image.png', path: '/tmp/image.png', skip_hash: 'abc')
    end
  end

  def test_store_media_requires_one_source
    client = RecordingClient.new

    assert_raises(ArgumentError) { client.store_media('empty.txt') }
    assert_raises(ArgumentError) { client.store_media('ambiguous.txt', data: 'eA==', path: '/tmp/x') }
    assert_empty client.requests
  end

  def test_ease_factor_lengths_must_match
    client = RecordingClient.new

    assert_raises(ArgumentError) { client.set_ease_factors([1, 2], [2500]) }
    assert_empty client.requests
  end

  def test_raw_card_values_action
    params = { card: 1, keys: [:flags], newValues: [2], warning_check: false }

    assert_request(:setSpecificValueOfCard, params) do |client|
      client.set_card_values(1, { flags: 2 })
    end
  end

  def test_answers_use_snake_case_card_ids
    assert_request(:answerCards, { answers: [{ cardId: 1, ease: 3 }] }) do |client|
      client.answer_cards([{ card_id: 1, ease: 3 }])
    end
  end

  def test_structured_inputs_report_their_context
    client = RecordingClient.new

    answer_error = assert_raises(ArgumentError) { client.answer_cards([{ unexpected: true }]) }
    reorder_error = assert_raises(ArgumentError) { client.gui_browse(reorder_cards: { unexpected: true }) }
    template_error = assert_raises(ArgumentError) do
      client.create_note_type(name: 'Test', fields: ['Front'], templates: [{ unexpected: true }])
    end

    assert_equal 'unknown answer key: unexpected', answer_error.message
    assert_equal 'unknown reorder_cards key: unexpected', reorder_error.message
    assert_equal 'unknown template key: unexpected', template_error.message
    assert_empty client.requests
  end

  def test_id_to_name_actions
    assert_request(:deckNameFromId, { deckId: 1 }) { |client| client.deck_name_from_id(1) }
    assert_request(:modelNameFromId, { modelId: 2 }) { |client| client.note_type_name_from_id(2) }
  end

  def test_deck_deletion_requires_explicit_confirmation
    client = RecordingClient.new

    assert_raises(ArgumentError) { client.delete_decks(['Test'], cards_too: false) }
    assert_empty client.requests
    assert_request(:deleteDecks, { decks: ['Test'], cardsToo: true }) do |recording_client|
      recording_client.delete_decks(['Test'], cards_too: true)
    end
  end

  def test_find_and_replace_uses_top_level_parameters
    params = {
      modelName: 'Basic', findText: 'old', replaceText: 'new', front: true, back: false, css: true
    }

    assert_request(:findAndReplaceInModels, params) do |client|
      client.find_and_replace_in_note_type(
        note_type_name: 'Basic', find: 'old', replace: 'new', back: false
      )
    end
  end

  def test_note_type_updates_map_to_atomic_actions
    assert_request(
      :updateModelTemplates,
      { model: { name: 'Basic', templates: { 'Card 1' => { Front: '{{Front}}' } } } }
    ) do |client|
      client.update_note_type_templates('Basic', 'Card 1' => { front: '{{Front}}' })
    end
    assert_request(:updateModelStyling, { model: { name: 'Basic', css: '.card {}' } }) do |client|
      client.update_note_type_styling('Basic', css: '.card {}')
    end
  end

  def test_gui_optional_actions
    assert_request(:guiBrowse) { |client| client.gui_browse }
    assert_request(:guiAddCards) { |client| client.gui_add_cards }
    assert_request(:guiReviewActive) { |client| client.gui_review_active? }
  end

  def test_gui_note_input_uses_note_type_terminology
    assert_request(:guiAddCards, { note: normalized_note }) { |client| client.gui_add_cards(NOTE) }
  end

  def test_gui_note_rejects_add_note_options
    client = RecordingClient.new

    assert_raises(ArgumentError) { client.gui_add_cards(NOTE.merge(options: { allow_duplicate: true })) }
    assert_empty client.requests
  end

  def test_miscellaneous_renames
    assert_request(:version) { |client| client.api_version }
    assert_request(:apiReflect, { scopes: ['actions'] }) do |client|
      client.api_capabilities(['actions'])
    end
    assert_request(:multi, { actions: [{ action: 'deckNames', version: 6 }] }) do |client|
      client.batch([{ action: 'deckNames', version: 6 }])
    end
    assert_request(:importPackage, { path: '/tmp/cards.apkg' }) do |client|
      client.import_package('/tmp/cards.apkg')
    end
  end

  def test_removed_0_1_entry_points_are_not_exposed
    client = RecordingClient.new
    old_methods = %i[
      api_reflect due? get_cards get_deck_config get_ease_factors get_note_ids get_notes get_reviews import_deck
      latest_review_time list_media media_dir_path model_names multi suspended? update_card version
    ]

    old_methods.each { |method| refute_respond_to client, method }
  end

  private

  def normalized_note
    { deckName: 'Default', modelName: 'Basic', fields: NOTE[:fields] }
  end
end
