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

      # Gets a deck name by ID.
      #
      # @param deck_id [Integer] Deck ID
      # @return [String] Deck name
      def deck_name_from_id(deck_id)
        request(:deckNameFromId, deckId: deck_id)
      end

      # Gets deck membership for given cards.
      #
      # @param card_ids [Array<Integer>] Array of card IDs
      # @return [Hash] Deck names mapped to arrays of card IDs
      def decks_for_cards(card_ids)
        request(:getDecks, cards: card_ids)
      end

      # Creates an empty deck without overwriting one with the same name.
      #
      # @param name [String] Deck name (use :: for hierarchy)
      # @return [Integer] Deck ID
      def create_deck(name)
        request(:createDeck, deck: name)
      end

      # Moves cards to a different deck, creating it if necessary.
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
      def delete_decks(names, cards_too:)
        raise ArgumentError, 'cards_too must be true to delete decks' unless cards_too == true

        request(:deleteDecks, decks: names, cardsToo: cards_too)
      end

      # Gets configuration for a deck.
      #
      # @param name [String] Deck name
      # @return [Hash, false] Wire-format configuration object, or false when the deck does not exist
      def deck_config(name)
        request(:getDeckConfig, deck: name)
      end

      # Saves a deck configuration.
      #
      # @param config [Hash] Complete object returned by {#deck_config}, with wire keys unchanged
      # @return [Boolean] true on success; false if the configuration group ID is invalid
      def save_deck_config(config)
        request(:saveDeckConfig, config: config)
      end

      # Changes the configuration group used by decks.
      #
      # @param names [Array<String>] Deck names
      # @param config_id [Integer] Configuration group ID
      # @return [Boolean] true on success; false if the group or a deck does not exist
      def set_deck_config(names, config_id)
        request(:setDeckConfigId, decks: names, configId: config_id)
      end

      # Creates a configuration group by cloning another group.
      #
      # @param name [String] Name for the new configuration group
      # @param clone_from [Integer, nil] Group to clone, or nil for the default group
      # @return [Integer, false] New group ID, or false if the source does not exist
      def clone_deck_config(name, clone_from: nil)
        params = { name: name }
        params[:cloneFrom] = clone_from if clone_from
        request(:cloneDeckConfigId, **params)
      end

      # Removes a deck configuration group.
      #
      # @param config_id [Integer] Configuration group ID
      # @return [Boolean] true on success; false for the default or a nonexistent group
      def remove_deck_config(config_id)
        request(:removeDeckConfigId, configId: config_id)
      end

      # Gets total-card and due-card statistics for decks.
      #
      # @param names [Array<String>] Array of deck names
      # @return [Hash] Deck IDs mapped to stats objects
      def deck_stats(names)
        request(:getDeckStats, decks: names)
      end
    end
  end
end
