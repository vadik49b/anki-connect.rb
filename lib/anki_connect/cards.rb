# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to query, modify, suspend, and manage individual flashcards.
    module Cards
      ANSWER_KEYS = {
        'card_id' => :cardId,
        'ease' => :ease
      }.freeze
      private_constant :ANSWER_KEYS

      # Gets ease factors for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Integer, nil>] Ease factors; nil for missing cards
      def ease_factors(card_ids)
        request(:getEaseFactors, cards: card_ids)
      end

      # Sets ease factors for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @param factors [Array<Integer>] Array of ease factor values
      # @return [Array<Boolean>] Array indicating success for each card
      def set_ease_factors(card_ids, factors)
        raise ArgumentError, 'card_ids and factors must have the same length' unless card_ids.length == factors.length

        request(:setEaseFactors, cards: card_ids, easeFactors: factors)
      end

      # Sets raw database values for a single card.
      # This low-level operation can corrupt scheduling data when used incorrectly.
      #
      # @param card_id [Integer] Card ID
      # @param fields [Hash] Database field names to new values
      # @param warning_check [Boolean] Must be true for certain risky keys
      # @return [Array, Boolean] Upstream result for the single card update
      def set_card_values(card_id, fields, warning_check: false)
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
      # @return [nil] Current AnkiConnect does not return the underlying result
      def unsuspend_cards(card_ids)
        request(:unsuspend, cards: card_ids)
      end

      # Checks whether one card is suspended.
      #
      # @param card_id [Integer] Card ID
      # @return [Boolean] Suspension status
      def card_suspended?(card_id)
        request(:suspended, card: card_id)
      end

      # Gets suspension status for each card, preserving input order.
      #
      # @param card_ids [Array<Integer>] Card IDs
      # @return [Array<Boolean, nil>] Statuses; nil for missing cards
      def card_suspension_statuses(card_ids)
        request(:areSuspended, cards: card_ids)
      end

      # Checks whether one card is due for review.
      #
      # @param card_id [Integer] Card ID
      # @return [Boolean] Due status
      def card_due?(card_id)
        request(:areDue, cards: [card_id]).first
      end

      # Gets due status for each card, preserving input order.
      #
      # @param card_ids [Array<Integer>] Card IDs
      # @return [Array<Boolean>] Due statuses
      def card_due_statuses(card_ids)
        request(:areDue, cards: card_ids)
      end

      # Gets intervals for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @param complete [Boolean] If true, returns all intervals
      # @return [Array<Integer>, Array<Array<Integer>>] Intervals
      def card_intervals(card_ids, complete: false)
        request(:getIntervals, cards: card_ids, complete: complete)
      end

      # Searches for cards matching a query.
      #
      # @param query [String] Anki search query string
      # @return [Array<Integer>] Array of card IDs
      def search_cards(query)
        request(:findCards, query: query)
      end

      # Gets unique parent note IDs for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Integer>] Unordered, unique note IDs
      def note_ids_for_cards(card_ids)
        request(:cardsToNotes, cards: card_ids)
      end

      # Gets modification times for cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Hash>] Array of objects with cardId and mod
      def card_modification_times(card_ids)
        request(:cardsModTime, cards: card_ids)
      end

      # Gets detailed information about cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Array<Hash>] Array of card objects
      def cards(card_ids)
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
      # @param answers [Array<Hash>] Array of { card_id:, ease: } (1=Again, 2=Hard, 3=Good, 4=Easy)
      # @return [Array<Boolean>] Array indicating if each card exists
      def answer_cards(answers)
        normalized = answers.map do |answer|
          answer = normalize_keys(answer, ANSWER_KEYS, name: 'answer')
          missing_keys = ANSWER_KEYS.values.reject { |key| answer.key?(key) }
          raise ArgumentError, "missing answer keys: #{missing_keys.join(', ')}" unless missing_keys.empty?

          answer
        end
        request(:answerCards, answers: normalized)
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
