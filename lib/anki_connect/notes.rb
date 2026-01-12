# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to create, update, query, and manage notes (which generate cards).
    module Notes
      # Creates a new note.
      #
      # @param deck_name [String] Target deck
      # @param model_name [String] Note type
      # @param fields [Hash] Field names to values
      # @param tags [Array<String>] Tags (optional)
      # @param media [Hash, nil] Media to add (audio:, video:, picture: arrays)
      # @param options [Hash, nil] Options (allowDuplicate, duplicateScope, etc.)
      # @return [Integer, nil] Note ID on success, nil on failure
      def add_note(deck_name:, model_name:, fields:, tags: [], media: nil, options: nil)
        note = { deckName: deck_name, modelName: model_name, fields: fields, tags: tags }
        note.merge!(media) if media
        note[:options] = options if options
        request(:addNote, note: note)
      end

      # Creates multiple notes.
      #
      # @param notes [Array<Hash>] Array of note hashes (same keys as add_note)
      # @return [Array<Integer, nil>] Array of note IDs (nil for failed notes)
      def add_notes(notes)
        request(:addNotes, notes: notes)
      end

      # Checks if notes can be added.
      #
      # @param notes [Array<Hash>] Array of candidate note objects
      # @param details [Boolean] If true, returns error details (default: false)
      # @return [Array<Boolean>, Array<Hash>] Array of booleans, or hashes with canAdd and error if details=true
      def can_add_notes(notes, details: false)
        if details
          request(:canAddNotesWithErrorDetail, notes: notes)
        else
          request(:canAddNotes, notes: notes)
        end
      end

      # Updates a note's fields, tags, or media.
      #
      # @param id [Integer] Note ID
      # @param fields [Hash, nil] Field names to new values
      # @param tags [Array<String>, nil] New tags (replaces existing)
      # @param media [Hash, nil] Media to add (audio:, video:, picture: arrays)
      # @return [nil]
      def update_note(id, fields: nil, tags: nil, media: nil)
        note = { id: id }
        note[:fields] = fields if fields
        note[:tags] = tags if tags
        note.merge!(media) if media
        request(:updateNote, note: note)
      end

      # Changes a note's model type.
      #
      # @param id [Integer] Note ID
      # @param model_name [String] New model name
      # @param fields [Hash] New field values
      # @param tags [Array<String>] New tags
      # @return [nil]
      def change_note_model(id, model_name:, fields:, tags:)
        request(:updateNoteModel, note: { id: id, modelName: model_name, fields: fields, tags: tags })
      end

      # Gets tags for a note.
      #
      # @param note_id [Integer] Note ID
      # @return [Array<String>] Array of tag strings
      def get_note_tags(note_id)
        request(:getNoteTags, note: note_id)
      end

      # Adds tags to notes.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @param tags [String, Array<String>] Tag(s) to add
      # @return [nil]
      def add_tags(note_ids, tags)
        request(:addTags, notes: note_ids, tags: tags)
      end

      # Removes tags from notes.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @param tags [String, Array<String>] Tag(s) to remove
      # @return [nil]
      def remove_tags(note_ids, tags)
        request(:removeTags, notes: note_ids, tags: tags)
      end

      # Gets all tags in collection.
      #
      # @return [Array<String>] Array of all tag strings
      def all_tags
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
      def get_notes(note_ids: nil, query: nil)
        params = {}
        params[:notes] = note_ids if note_ids
        params[:query] = query if query
        request(:notesInfo, **params)
      end

      # Gets modification times for notes.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @return [Array<Hash>] Array of objects with noteId and mod
      def get_notes_mod_time(note_ids)
        request(:notesModTime, notes: note_ids)
      end

      # Deletes notes and all associated cards.
      #
      # @param note_ids [Array<Integer>] Array of note IDs
      # @return [nil]
      def delete_notes(note_ids)
        request(:deleteNotes, notes: note_ids)
      end

      # Removes all empty notes.
      #
      # @return [nil]
      def remove_empty_notes
        request(:removeEmptyNotes)
      end
    end
  end
end
