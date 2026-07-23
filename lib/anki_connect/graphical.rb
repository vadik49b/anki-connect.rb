# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to interact with Anki's GUI windows and dialogs
    # (card browser, review screen, editing interfaces).
    module Graphical
      REORDER_CARD_KEYS = {
        'order' => :order,
        'column_id' => :columnId
      }.freeze
      private_constant :REORDER_CARD_KEYS

      # Opens Card Browser dialog and searches for query.
      #
      # @param query [String, nil] Search query string; nil preserves the current browser search
      # @param reorder_cards [Hash, nil] Object with order and column_id
      # @return [Array<Integer>] Array of card IDs found
      def gui_browse(query = nil, reorder_cards: nil)
        params = {}
        params[:query] = query unless query.nil?
        if reorder_cards
          normalized = normalize_keys(reorder_cards, REORDER_CARD_KEYS, name: 'reorder_cards')
          missing_keys = REORDER_CARD_KEYS.values.reject { |key| normalized.key?(key) }
          raise ArgumentError, "missing reorder_cards keys: #{missing_keys.join(', ')}" unless missing_keys.empty?

          params[:reorderCards] = normalized
        end
        request(:guiBrowse, **params)
      end

      # Selects a card in the open Card Browser.
      #
      # @param card_id [Integer] Card ID
      # @return [Boolean] true if browser is open, false otherwise
      def gui_select_card(card_id)
        request(:guiSelectCard, card: card_id)
      end

      # Gets selected notes from open Card Browser.
      #
      # @return [Array<Integer>] Array of note IDs (empty if browser not open)
      def gui_selected_notes
        request(:guiSelectedNotes)
      end

      # Opens Add Cards dialog with preset values.
      # Multiple invocations close old window and reopen with new values.
      #
      # @param note [Hash, nil] Optional note preset
      # @return [Integer] Note ID that would be created if user confirms
      def gui_add_cards(note = nil)
        params = {}
        params[:note] = normalize_gui_note(note) unless note.nil?
        request(:guiAddCards, **params)
      end

      # Opens Edit dialog for a note.
      # Opens edit dialog with Preview, Browse, and navigation buttons.
      #
      # @param note_id [Integer] Note ID
      # @return [nil]
      def gui_edit_note(note_id)
        request(:guiEditNote, note: note_id)
      end

      # Sets fields/tags/deck/model in open Add Note dialog.
      # Returns error if Add Note dialog not open. Deck/model always replace; fields/tags respect append flag.
      #
      # @param note [Hash] Note with optional deck_name, note_type_name, fields, tags, and media
      # @param append [Boolean] If true, appends to fields/tags; otherwise replaces (default: false)
      # @return [Boolean, Hash] true on success, or an error hash when the dialog is closed
      def gui_add_note_set_data(note, append: false)
        request(:guiAddNoteSetData, note: normalize_gui_note(note), append: append)
      end

      # Checks whether the review screen has an active card.
      #
      # @return [Boolean] true when review is active
      def gui_review_active?
        request(:guiReviewActive)
      end

      # Gets information about current card in review.
      #
      # @return [Hash] Current card information
      # @raise [APIError] If review is not active
      def gui_current_card
        request(:guiCurrentCard)
      end

      # Starts/resets timer for current card.
      # Useful for accurate time tracking when displaying cards via API.
      #
      # @return [Boolean] false when review is not active or no card is available
      def gui_start_card_timer
        request(:guiStartCardTimer)
      end

      # Shows question side of current card.
      #
      # @return [Boolean] true if in review mode, false otherwise
      def gui_show_question
        request(:guiShowQuestion)
      end

      # Shows answer side of current card.
      #
      # @return [Boolean] true if in review mode, false otherwise
      def gui_show_answer
        request(:guiShowAnswer)
      end

      # Answers the current card.
      # Answer must be displayed before answering.
      #
      # @param ease [Integer] Answer button (1-4)
      # @return [Boolean] true on success, false otherwise
      def gui_answer_card(ease)
        request(:guiAnswerCard, ease: ease)
      end

      # Undoes last action/card.
      #
      # @return [Boolean] true on success, false otherwise
      def gui_undo
        request(:guiUndo)
      end

      # Opens Deck Overview dialog for a deck.
      #
      # @param name [String] Deck name
      # @return [Boolean] true on success, false otherwise
      def gui_deck_overview(name)
        request(:guiDeckOverview, name: name)
      end

      # Opens Deck Browser dialog.
      #
      # @return [nil]
      def gui_deck_browser
        request(:guiDeckBrowser)
      end

      # Starts review for a deck.
      #
      # @param name [String] Deck name
      # @return [Boolean] true on success, false otherwise
      def gui_deck_review(name)
        request(:guiDeckReview, name: name)
      end

      # Opens Import dialog with optional file path.
      # Opens file dialog if no path provided. Forward slashes required on Windows. Anki 2.1.52+ only.
      #
      # @param path [String, nil] File path to import (optional)
      # @return [nil]
      def gui_import_file(path: nil)
        params = {}
        params[:path] = path if path
        request(:guiImportFile, **params)
      end

      # Schedules graceful Anki shutdown.
      # Asynchronous - returns immediately without waiting for termination.
      #
      # @return [nil]
      def gui_exit_anki
        request(:guiExitAnki)
      end

      # Requests database check.
      # Returns immediately without waiting for check to complete.
      #
      # @return [Boolean] true (always)
      def gui_check_database
        request(:guiCheckDatabase)
      end

      # Plays audio for current card side.
      #
      # @return [Boolean] true on success, false otherwise
      def gui_play_audio
        request(:guiPlayAudio)
      end
    end
  end
end
