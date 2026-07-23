# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods for API permissions, version checking, profile management,
    # synchronization, and import/export.
    module Miscellaneous
      # Requests API permission (first call to establish trust).
      # Only method accepting requests from any origin. Shows popup for untrusted origins.
      #
      # @return [Hash] Object with permission and optionally requireApikey and version
      def request_permission
        request(:requestPermission)
      end

      # Gets AnkiConnect API version.
      #
      # @return [Integer] Version number (currently 6)
      def api_version
        request(:version)
      end

      # Gets information about available APIs.
      #
      # @param scopes [Array<String>] Array of scope names (currently only "actions" supported)
      # @param actions [Array<String>, nil] null for all actions, or array of action names to check (optional)
      # @return [Hash] Object with scopes used and available actions
      def api_capabilities(scopes, actions: nil)
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
      # @return [Boolean] true on success, false when the profile does not exist
      def load_profile(name)
        request(:loadProfile, name: name)
      end

      # Performs multiple actions in one request.
      # Unlike convenience wrappers, each action uses AnkiConnect's raw wire keys.
      #
      # @param actions [Array<Hash>] Raw wire action objects with action, version, and params
      # @return [Array] Array of responses in same order
      # @see #request Use request for individual actions
      def batch(actions)
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
      # @param path [String] Package file path on the Anki host
      # @return [Boolean] true on success, false otherwise
      def import_package(path)
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
