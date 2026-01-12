# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to query review counts, retrieve review history,
    # and access collection statistics.
    module Statistics
      # Gets count of cards reviewed today.
      # "Today" uses day start time as configured in Anki.
      #
      # @return [Integer] Count of cards reviewed today
      def cards_reviewed_today
        request(:getNumCardsReviewedToday)
      end

      # Gets review counts by day.
      #
      # @return [Array<Array>] Array of [dateString, count] pairs
      def cards_reviewed_by_day
        request(:getNumCardsReviewedByDay)
      end

      # Gets collection statistics report as HTML.
      #
      # @param whole_collection [Boolean] Whether to get stats for whole collection (default: true)
      # @return [String] HTML string
      def collection_stats_html(whole_collection: true)
        request(:getCollectionStatsHTML, wholeCollection: whole_collection)
      end

      # Gets all card reviews for a deck after a certain time.
      #
      # @param deck_name [String] Deck name
      # @param after [Integer] Unix timestamp (reviews after this time, exclusive)
      # @return [Array<Array>] Array of 9-tuples: (reviewTime, cardID, usn, buttonPressed, newInterval, previousInterval, newFactor, reviewDuration, reviewType)
      def get_reviews(deck_name, after:)
        request(:cardReviews, deck: deck_name, startID: after)
      end

      # Gets all reviews for specific cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Hash] Dictionary mapping card IDs to arrays of review objects with id, usn, ease, ivl, lastIvl, factor, time, type
      def get_reviews_for_cards(card_ids)
        request(:getReviewsOfCards, cards: card_ids)
      end

      # Gets unix time of latest review for a deck.
      #
      # @param deck_name [String] Deck name
      # @return [Integer] Unix timestamp, or 0 if no reviews
      def latest_review_time(deck_name)
        request(:getLatestReviewID, deck: deck_name)
      end

      # Inserts review records into database.
      #
      # @param reviews [Array<Array>] Array of 9-tuples (same format as get_reviews output)
      # @return [nil]
      def insert_reviews(reviews)
        request(:insertReviews, reviews: reviews)
      end
    end
  end
end
