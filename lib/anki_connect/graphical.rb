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

      # Opens the Card Browser, searches for a query, and optionally reorders the cards.
      #
      # @param query [String, nil] Anki search query; nil preserves the current browser search
      # @param reorder_cards [Hash, nil] order and visible column_id used to sort the results
      # @return [Array<Integer>] IDs of cards found
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

      # Opens Add Cards with optional preset values; repeated calls replace the window.
      #
      # @param note [Hash, nil] Optional note preset
      # @return [Integer] Note ID that would be created if user confirms
      def gui_add_cards(note = nil)
        params = {}
        params[:note] = normalize_gui_note(note) unless note.nil?
        request(:guiAddCards, **params)
      end

      # Opens the note editor with preview, browsing, and navigation controls.
      #
      # @param note_id [Integer] Note ID
      # @return [nil]
      def gui_edit_note(note_id)
        request(:guiEditNote, note: note_id)
      end

      # Sets Add Note data. Deck and note type replace; fields and tags honor append.
      # Requires AnkiConnect commit de6e6e1 or later; unavailable in 25.11.9.0.
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

      # Resets the current card timer for accurate API-driven review timing.
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

      # Answers the current card. The answer must be displayed first.
      #
      # @param ease [Integer] Available answer button number
      # @return [Boolean] true on success; false if review is inactive, the answer is hidden, or ease is invalid
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

      # Opens Import for user review. Without a path, opens a file chooser.
      # Supports all Anki import types; Windows paths use forward slashes. Requires Anki 2.1.52+.
      #
      # @param path [String, nil] Optional file path on the Anki host
      # @return [nil]
      def gui_import_file(path: nil)
        params = {}
        params[:path] = path if path
        request(:guiImportFile, **params)
      end

      # Schedules shutdown and returns immediately.
      #
      # @return [nil]
      def gui_exit_anki
        request(:guiExitAnki)
      end

      # Starts a database check and returns immediately.
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
