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
      # @param overwrite [Boolean] If true, overwrites existing file
      # @return [String] Filename (possibly modified if overwrite=false)
      def store_media(filename, data: nil, path: nil, url: nil, overwrite: true)
        params = { filename: filename, deleteExisting: overwrite }
        params[:data] = data if data
        params[:path] = path if path
        params[:url] = url if url
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
      def list_media(pattern: '*')
        request(:getMediaFilesNames, pattern: pattern)
      end

      # Gets the media folder path.
      #
      # @return [String] Absolute path
      def media_dir_path
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
