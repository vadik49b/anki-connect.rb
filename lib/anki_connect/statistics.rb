# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to query review counts, retrieve review history,
    # and access collection statistics.
    module Statistics
      # Gets cards reviewed since Anki's configured day-start time.
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

      # Gets all card reviews for a deck after a review log ID.
      #
      # @param deck_name [String] Deck name
      # @param after [Integer] Review log ID in epoch milliseconds (exclusive)
      # @return [Array<Array>] Review rows with time, card ID, USN, button, intervals, factor, duration, and type
      def reviews(deck_name, after:)
        request(:cardReviews, deck: deck_name, startID: after)
      end

      # Gets all reviews for specific cards.
      #
      # @param card_ids [Array<Integer>] Card IDs
      # @return [Hash] Arrays of review objects keyed by card ID, retaining AnkiConnect wire keys
      def reviews_for_cards(card_ids)
        request(:getReviewsOfCards, cards: card_ids)
      end

      # Gets the latest review log ID for a deck.
      #
      # @param deck_name [String] Deck name
      # @return [Integer] Review log ID in epoch milliseconds, or 0 if no reviews
      def latest_review_id(deck_name)
        request(:getLatestReviewID, deck: deck_name)
      end

      # Inserts review records into database.
      #
      # @param reviews [Array<Array>] Array of 9-tuples (same format as reviews output)
      # @return [nil]
      def insert_reviews(reviews)
        request(:insertReviews, reviews: reviews)
      end
    end
  end
end
