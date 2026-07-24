# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to create, update, query, and manage notes (which generate cards).
    module Notes
      # Creates a new note.
      #
      # @param deck_name [String] Target deck
      # @param note_type_name [String] Note type
      # @param fields [Hash] Field names to values
      # @param tags [Array<String>] Tags (optional)
      # @param media [Hash, nil] Optional audio, video, or picture items with filename and a source
      # @param options [Hash, nil] Options such as allow_duplicate and duplicate_scope
      # @return [Integer] Note ID on success
      def add_note(deck_name:, note_type_name:, fields:, tags: [], media: nil, options: nil)
        note = { deck_name: deck_name, note_type_name: note_type_name, fields: fields, tags: tags }
        note[:media] = media unless media.nil?
        note[:options] = options unless options.nil?
        request(:addNote, note: normalize_note(note))
      end

      # Creates notes, gathering all errors and rolling back the additions if any fail.
      #
      # @param notes [Array<Hash>] Array of note hashes (same keys as add_note)
      # @return [Array<Integer>] Array of note IDs
      def add_notes(notes)
        request(:addNotes, notes: notes.map { |note| normalize_note(note) })
      end

      # Checks if one note can be added.
      #
      # @param note [Hash] Candidate note using snake_case keys
      # @return [Boolean] Whether the note can be added
      def note_addable?(note)
        request(:canAddNote, note: normalize_note(note))
      end

      # Gets addability details for one note.
      #
      # @param note [Hash] Candidate note
      # @return [Hash] Hash with canAdd and optional error
      def note_addability(note)
        request(:canAddNoteWithErrorDetail, note: normalize_note(note))
      end

      # Gets addability status for each note, preserving input order.
      #
      # @param notes [Array<Hash>] Candidate notes
      # @return [Array<Boolean>] Addability statuses
      def note_addability_statuses(notes)
        request(:canAddNotes, notes: notes.map { |note| normalize_note(note) })
      end

      # Gets addability details for each note, preserving input order.
      #
      # @param notes [Array<Hash>] Candidate notes
      # @return [Array<Hash>] Hashes with canAdd and optional error
      def note_addability_details(notes)
        request(:canAddNotesWithErrorDetail, notes: notes.map { |note| normalize_note(note) })
      end

      # Updates a note's fields, tags, or media.
      #
      # @param id [Integer] Note ID
      # @param fields [Hash, nil] Field names to new values
      # @param tags [Array<String>, nil] New tags (replaces existing)
      # @param media [Hash, nil] Optional audio, video, or picture items with filename and a source
      # @return [nil]
      def update_note(id, fields: nil, tags: nil, media: nil)
        if fields.nil? && tags.nil? && media.nil?
          raise ArgumentError, 'provide fields, tags, or media to update'
        end

        note = { id: id }
        note[:fields] = fields || {} unless fields.nil? && media.nil?
        note[:tags] = tags unless tags.nil?
        merge_media!(note, media) unless media.nil?
        request(:updateNote, note: note)
      end

      # Updates a note's fields and optional media.
      #
      # @param id [Integer] Note ID
      # @param fields [Hash] Field names to new values
      # @param media [Hash, nil] Media to add (audio:, video:, picture:)
      # @return [nil]
      def update_note_fields(id, fields:, media: nil)
        note = { id: id, fields: fields }
        merge_media!(note, media) unless media.nil?
        request(:updateNoteFields, note: note)
      end

      # Replaces all tags on a note.
      #
      # @param id [Integer] Note ID
      # @param tags [String, Array<String>] Replacement tags
      # @return [nil]
      def update_note_tags(id, tags)
        request(:updateNoteTags, note: id, tags: normalize_note_tags(tags))
      end

      # Changes a note's note type.
      #
      # @param id [Integer] Note ID
      # @param note_type_name [String] New note type name
      # All fields not supplied are cleared when the note type changes.
      #
      # @param fields [Hash] Complete values for fields in the new note type
      # @param tags [Array<String>] Replacement tags
      # @return [nil]
      def change_note_type(id, note_type_name:, fields:, tags:)
        request(:updateNoteModel, note: { id: id, modelName: note_type_name, fields: fields, tags: tags })
      end

      # Gets tags for a note.
      #
      # @param note_id [Integer] Note ID
      # @return [Array<String>] Array of tag strings
      def note_tags(note_id)
        request(:getNoteTags, note: note_id)
      end

      # Adds tags to notes.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @param tags [String, Array<String>] Tag(s) to add
      # @return [nil]
      def add_tags(note_ids, tags)
        request(:addTags, notes: note_ids, tags: normalize_tag_query(tags))
      end

      # Removes tags from notes.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @param tags [String, Array<String>] Tag(s) to remove
      # @return [nil]
      def remove_tags(note_ids, tags)
        request(:removeTags, notes: note_ids, tags: normalize_tag_query(tags))
      end

      # Gets all tags in collection.
      #
      # @return [Array<String>] Array of all tag strings
      def tags
        request(:getTags)
      end

      # Removes unused tags from collection.
      #
      # @return [nil]
      def clear_unused_tags
        request(:clearUnusedTags)
      end

      # Replaces a tag with another.
      #
      # @param from [String] Old tag
      # @param to [String] New tag
      # @param note_ids [Array<Integer>, nil] Specific notes, or nil for all notes
      # @return [nil]
      def replace_tag(from:, to:, note_ids: nil)
        if note_ids
          request(:replaceTags, notes: note_ids, tag_to_replace: from, replace_with_tag: to)
        else
          request(:replaceTagsInAllNotes, tag_to_replace: from, replace_with_tag: to)
        end
      end

      # Searches for notes matching a query.
      #
      # @param query [String] Search query string
      # @return [Array<Integer>] Array of note IDs
      def search_notes(query)
        request(:findNotes, query: query)
      end

      # Gets detailed information about notes.
      #
      # @param note_ids [Array<Integer>, nil] Array of note IDs
      # @param query [String, nil] Search query string
      # @return [Array<Hash>] Array of note objects
      def notes(note_ids: nil, query: nil)
        unless [note_ids, query].count { |selector| !selector.nil? } == 1
          raise ArgumentError, 'provide exactly one of note_ids or query'
        end

        params = note_ids.nil? ? { query: query } : { notes: note_ids }
        request(:notesInfo, **params)
      end

      # Gets modification times for notes.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @return [Array<Hash>] Array of objects with noteId and mod
      def note_modification_times(note_ids)
        request(:notesModTime, notes: note_ids)
      end

      # Deletes notes and all associated cards.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @return [nil]
      def delete_notes(note_ids)
        request(:deleteNotes, notes: note_ids)
      end

      # Removes note types that are not used by any notes.
      # The upstream action name is misleading; it does not remove notes with empty fields.
      #
      # @return [nil]
      def remove_unused_note_types
        request(:removeEmptyNotes)
      end

      private

      NOTE_KEYS = {
        'deck_name' => :deckName,
        'note_type_name' => :modelName,
        'fields' => :fields,
        'tags' => :tags,
        'options' => :options,
        'media' => :media,
        'audio' => :audio,
        'video' => :video,
        'picture' => :picture
      }.freeze
      GUI_NOTE_KEYS = NOTE_KEYS.reject { |key, _value| key == 'options' }.freeze
      MEDIA_KEYS = {
        'audio' => :audio,
        'video' => :video,
        'picture' => :picture
      }.freeze
      OPTION_KEYS = {
        'allow_duplicate' => :allowDuplicate,
        'duplicate_scope' => :duplicateScope,
        'duplicate_scope_options' => :duplicateScopeOptions
      }.freeze
      SCOPE_OPTION_KEYS = {
        'deck_name' => :deckName,
        'check_children' => :checkChildren,
        'check_all_note_types' => :checkAllModels
      }.freeze
      MEDIA_ITEM_KEYS = {
        'filename' => :filename,
        'fields' => :fields,
        'data' => :data,
        'path' => :path,
        'url' => :url,
        'skip_hash' => :skipHash,
        'overwrite' => :deleteExisting
      }.freeze
      private_constant :NOTE_KEYS, :GUI_NOTE_KEYS, :MEDIA_KEYS, :OPTION_KEYS, :SCOPE_OPTION_KEYS, :MEDIA_ITEM_KEYS

      def normalize_note(note, key_map: NOTE_KEYS)
        normalized = normalize_keys(note, key_map, name: 'note') do |key, value|
          if key == :options
            normalize_options(value)
          elsif MEDIA_KEYS.value?(key)
            normalize_media(value)
          else
            value
          end
        end

        merge_media!(normalized, normalized.delete(:media)) if normalized.key?(:media)
        normalized
      end

      def normalize_gui_note(note)
        normalize_note(note, key_map: GUI_NOTE_KEYS)
      end

      def merge_media!(note, media)
        normalized_media = normalize_keys(media, MEDIA_KEYS, name: 'media') do |_key, value|
          normalize_media(value)
        end
        normalized_media.each do |key, value|
          raise ArgumentError, "duplicate media key: #{key}" if note.key?(key)

          note[key] = value
        end
      end

      def normalize_note_tags(tags)
        tags = [tags] if tags.is_a?(String)
        unless tags.is_a?(Array) && tags.all? { |tag| tag.is_a?(String) }
          raise ArgumentError, 'tags must be a String or an Array of Strings'
        end

        tags
      end

      def normalize_tag_query(tags)
        normalize_note_tags(tags).join(' ')
      end

      def normalize_options(options)
        normalize_keys(options, OPTION_KEYS, name: 'options') do |key, value|
          key == :duplicateScopeOptions ? normalize_keys(value, SCOPE_OPTION_KEYS, name: 'duplicate_scope_options') : value
        end
      end

      def normalize_media(media)
        media.is_a?(Array) ? media.map { |item| normalize_media_item(item) } : normalize_media_item(media)
      end

      def normalize_media_item(item)
        normalize_keys(item, MEDIA_ITEM_KEYS, name: 'media item')
      end
    end
  end
end
