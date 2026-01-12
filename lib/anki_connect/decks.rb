# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to create, configure, and manage decks and their settings.
    module Decks
      # Gets complete list of deck names.
      #
      # @return [Array<String>] Array of deck name strings
      def deck_names
        request(:deckNames)
      end

      # Gets deck names with their IDs.
      #
      # @return [Hash] Deck names mapped to IDs
      def deck_names_and_ids
        request(:deckNamesAndIds)
      end

      # Gets deck membership for given cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Hash] Deck names mapped to arrays of card IDs
      def get_decks_for_cards(card_ids)
        request(:getDecks, cards: card_ids)
      end

      # Creates a new empty deck.
      #
      # @param name [String] Deck name (use :: for hierarchy)
      # @return [Integer] Deck ID
      def create_deck(name)
        request(:createDeck, deck: name)
      end

      # Moves cards to a different deck.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @param to [String] Target deck name
      # @return [nil]
      def move_cards(card_ids, to:)
        request(:changeDeck, cards: card_ids, deck: to)
      end

      # Deletes decks by name.
      #
      # @param names [Array<String>] Array of deck names
      # @param cards_too [Boolean] Must be true to confirm deletion
      # @return [nil]
      def delete_decks(names, cards_too: true)
        request(:deleteDecks, decks: names, cardsToo: cards_too)
      end

      # Gets configuration for a deck.
      #
      # @param name [String] Deck name
      # @return [Hash] Configuration object
      def get_deck_config(name)
        request(:getDeckConfig, deck: name)
      end

      # Saves a deck configuration.
      #
      # @param config [Hash] Complete configuration object
      # @return [Boolean] true on success
      def save_deck_config(config)
        request(:saveDeckConfig, config: config)
      end

      # Sets configuration for decks.
      #
      # @param names [Array<String>] Array of deck names
      # @param config_id [Integer] Configuration group ID
      # @return [Boolean] true on success
      def set_deck_config(names, config_id)
        request(:setDeckConfigId, decks: names, configId: config_id)
      end

      # Clones a deck configuration.
      #
      # @param name [String] Name for new config group
      # @param clone_from [Integer, nil] Config ID to clone from
      # @return [Integer, Boolean] New config ID, or false if source doesn't exist
      def clone_deck_config(name, clone_from: nil)
        params = { name: name }
        params[:cloneFrom] = clone_from if clone_from
        request(:cloneDeckConfigId, **params)
      end

      # Removes a deck configuration.
      #
      # @param config_id [Integer] Configuration group ID
      # @return [Boolean] true on success
      def remove_deck_config(config_id)
        request(:removeDeckConfigId, configId: config_id)
      end

      # Gets statistics for decks.
      #
      # @param names [Array<String>] Array of deck names
      # @return [Hash] Deck IDs mapped to stats objects
      def get_deck_stats(names)
        request(:getDeckStats, decks: names)
      end
    end
  end
end
