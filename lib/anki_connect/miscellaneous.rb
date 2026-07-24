# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods for API permissions, version checking, profile management,
    # synchronization, and import/export.
    module Miscellaneous
      # Requests API permission without an API key. Untrusted origins prompt the user;
      # localhost is trusted by default.
      #
      # @return [Hash] permission and, when granted, requireApiKey and version
      def request_permission
        request(:requestPermission)
      end

      # Gets the API version exposed by AnkiConnect.
      #
      # @return [Integer] API version; versions 1 through 6 are defined
      def api_version
        request(:version)
      end

      # Gets reflection information about available AnkiConnect APIs.
      #
      # @param scopes [Array<String>] Scopes to inspect; currently only "actions" is supported
      # @param actions [Array<String>, nil] nil for all actions, or names to filter
      # @return [Hash] Accepted scopes and their available values
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

      # Executes raw action envelopes (action, version, and wire-format params) in one request.
      # Prefer named wrappers, or {#request} for one action.
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

      # Imports an .apkg file into the collection.
      #
      # @param path [String] Path relative to Anki's collection.media directory
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
