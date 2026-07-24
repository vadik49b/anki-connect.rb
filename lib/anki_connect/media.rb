# frozen_string_literal: true

module AnkiConnect
  class Client
    # Methods to store, retrieve, and manage media files.
    module Media
      # Stores a file in the media folder.
      #
      # @param filename [String] File name (prefix with _ to prevent auto-deletion)
      # @param data [String, nil] Base64-encoded contents
      # @param path [String, nil] Absolute file path
      # @param url [String, nil] URL to download from
      # @param skip_hash [String, nil] MD5 hash that causes identical contents to be skipped
      # @param overwrite [Boolean] Replace an existing file; false chooses a non-conflicting name
      # @return [String, nil] Stored filename, or nil when skipped by hash
      def store_media(filename, data: nil, path: nil, url: nil, skip_hash: nil, overwrite: true)
        sources = { data: data, path: path, url: url }.reject { |_key, value| value.nil? }
        raise ArgumentError, 'provide exactly one of data, path, or url' unless sources.one?

        params = { filename: filename, deleteExisting: overwrite }
        params.merge!(sources)
        params[:skipHash] = skip_hash unless skip_hash.nil?
        request(:storeMediaFile, **params)
      end

      # Retrieves a media file's contents.
      #
      # @param filename [String] File name
      # @return [String, Boolean] Base64-encoded contents, or false if not found
      def retrieve_media(filename)
        request(:retrieveMediaFile, filename: filename)
      end

      # Lists media files matching a pattern.
      #
      # @param pattern [String] Glob pattern
      # @return [Array<String>] Array of filenames
      def media_files(pattern: '*')
        request(:getMediaFilesNames, pattern: pattern)
      end

      # Gets the media folder path.
      #
      # @return [String] Absolute path
      def media_directory
        request(:getMediaDirPath)
      end

      # Deletes a media file.
      #
      # @param filename [String] File name
      # @return [nil]
      def delete_media(filename)
        request(:deleteMediaFile, filename: filename)
      end
    end
  end
end
