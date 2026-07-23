# frozen_string_literal: true

module AnkiConnect
  class Client
    # Shared normalization for snake_case convenience inputs.
    module Params
      private

      def normalize_keys(hash, key_map, name: 'parameters')
        raise ArgumentError, "#{name} must be a Hash" unless hash.is_a?(Hash)

        hash.each_with_object({}) do |(key, value), normalized|
          normalized_key = key_map[key.to_s]
          raise ArgumentError, "unknown #{name} key: #{key}" unless normalized_key
          raise ArgumentError, "duplicate #{name} key: #{normalized_key}" if normalized.key?(normalized_key)

          normalized[normalized_key] = block_given? ? yield(normalized_key, value) : value
        end
      end
    end
  end
end
