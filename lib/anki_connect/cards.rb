# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to query, modify, suspend, and manage individual flashcards.
    module Cards
      # Gets ease factors for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Integer>] Array of ease factor values
      def get_ease_factors(card_ids)
        request(:getEaseFactors, cards: card_ids)
      end

      # Sets ease factors for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @param factors [Array<Integer>] Array of ease factor values
      # @return [Array<Boolean>] Array indicating success for each card
      def set_ease_factors(card_ids, factors)
        request(:setEaseFactors, cards: card_ids, easeFactors: factors)
      end

      # Sets specific database values for a single card.
      #
      # @param card_id [Integer] Card ID
      # @param fields [Hash] Database field names to new values
      # @param warning_check [Boolean] Must be true for certain risky keys
      # @return [Array<Boolean>] Array indicating success for each field
      def update_card(card_id, fields, warning_check: false)
        request(:setSpecificValueOfCard, card: card_id, keys: fields.keys, newValues: fields.values,
                                         warning_check: warning_check)
      end

      # Suspends cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Boolean] true if at least one card wasn't already suspended
      def suspend_cards(card_ids)
        request(:suspend, cards: card_ids)
      end

      # Unsuspends cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Boolean] true if at least one card was previously suspended
      def unsuspend_cards(card_ids)
        request(:unsuspend, cards: card_ids)
      end

      # Checks suspension status for cards.
      #
      # @param card_ids [Integer, Array<Integer>] Single card ID or array
      # @return [Boolean, Array<Boolean, nil>] Boolean for single, array for multiple
      def suspended?(card_ids)
        if card_ids.is_a?(Array)
          request(:areSuspended, cards: card_ids)
        else
          request(:suspended, card: card_ids)
        end
      end

      # Checks if cards are due for review.
      #
      # @param card_ids [Integer, Array<Integer>] Single card ID or array
      # @return [Boolean, Array<Boolean>] Boolean for single, array for multiple
      def due?(card_ids)
        if card_ids.is_a?(Array)
          request(:areDue, cards: card_ids)
        else
          request(:areDue, cards: [card_ids]).first
        end
      end

      # Gets intervals for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @param complete [Boolean] If true, returns all intervals
      # @return [Array<Integer>, Array<Array<Integer>>] Intervals
      def get_intervals(card_ids, complete: false)
        request(:getIntervals, cards: card_ids, complete: complete)
      end

      # Searches for cards matching a query.
      #
      # @param query [String] Anki search query string
      # @return [Array<Integer>] Array of card IDs
      def search_cards(query)
        request(:findCards, query: query)
      end

      # Converts card IDs to their parent note IDs.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Integer>] Array of note IDs
      def get_note_ids(card_ids)
        request(:cardsToNotes, cards: card_ids)
      end

      # Gets modification times for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Hash>] Array of objects with cardId and mod
      def get_cards_mod_time(card_ids)
        request(:cardsModTime, cards: card_ids)
      end

      # Gets detailed information about cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Hash>] Array of card objects
      def get_cards(card_ids)
        request(:cardsInfo, cards: card_ids)
      end

      # Resets cards to "new" status.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [nil]
      def forget_cards(card_ids)
        request(:forgetCards, cards: card_ids)
      end

      # Makes cards enter "relearning" state.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [nil]
      def relearn_cards(card_ids)
        request(:relearnCards, cards: card_ids)
      end

      # Answers cards programmatically.
      #
      # @param answers [Array<Hash>] Array of { cardId:, ease: } (1=Again, 2=Hard, 3=Good, 4=Easy)
      # @return [Array<Boolean>] Array indicating if each card exists
      def answer_cards(answers)
        request(:answerCards, answers: answers)
      end

      # Sets due date for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @param days [String, Integer] Due date (0=today, 1!=tomorrow, 3-7=random range)
      # @return [Boolean] true on success
      def set_due_date(card_ids, days)
        request(:setDueDate, cards: card_ids, days: days)
      end
    end
  end
end
