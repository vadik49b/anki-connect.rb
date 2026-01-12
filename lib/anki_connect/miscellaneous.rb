# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods for API permissions, version checking, profile management,
    # synchronization, and import/export.
    module Miscellaneous
      # Requests API permission (first call to establish trust).
      # Only method accepting requests from any origin. Shows popup for untrusted origins.
      #
      # @return [Hash] Object with permission (granted/denied), and optionally requireApiKey and version
      def request_permission
        request(:requestPermission)
      end

      # Gets AnkiConnect API version.
      #
      # @return [Integer] Version number (currently 6)
      def version
        request(:version)
      end

      # Gets information about available APIs.
      #
      # @param scopes [Array<String>] Array of scope names (currently only "actions" supported)
      # @param actions [Array<String>, nil] null for all actions, or array of action names to check (optional)
      # @return [Hash] Object with scopes used and available actions
      def api_reflect(scopes, actions: nil)
        params = { scopes: scopes }
        params[:actions] = actions if actions
        request(:apiReflect, **params)
      end

      # Synchronizes local collection with AnkiWeb.
      #
      # @return [nil]
      def sync
        request(:sync)
      end

      # Retrieves list of profiles.
      #
      # @return [Array<String>] Array of profile names
      def profiles
        request(:getProfiles)
      end

      # Gets the active profile.
      #
      # @return [String] Profile name string
      def active_profile
        request(:getActiveProfile)
      end

      # Switches to specified profile.
      #
      # @param name [String] Profile name
      # @return [Boolean] true on success
      def load_profile(name)
        request(:loadProfile, name: name)
      end

      # Performs multiple actions in one request.
      #
      # @param actions [Array<Hash>] Array of action objects (each with action, version, params)
      # @return [Array] Array of responses in same order
      def multi(actions)
        request(:multi, actions: actions)
      end

      # Exports deck to .apkg format.
      #
      # @param deck_name [String] Deck name
      # @param path [String] Output file path
      # @param include_scheduling [Boolean] Include scheduling data (default: false)
      # @return [Boolean] true on success, false otherwise
      def export_deck(deck_name, path, include_scheduling: false)
        request(:exportPackage, deck: deck_name, path: path, includeSched: include_scheduling)
      end

      # Imports .apkg file into collection.
      #
      # @param path [String] File path (relative to collection.media folder)
      # @return [Boolean] true on success, false otherwise
      def import_deck(path)
        request(:importPackage, path: path)
      end

      # Reloads all data from database.
      #
      # @return [nil]
      def reload_collection
        request(:reloadCollection)
      end
    end
  end
end
