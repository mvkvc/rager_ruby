# typed: strict
# frozen_string_literal: true

require "dry-schema"
require "sorbet-runtime"

module Rager
  module Chat
    class Options < T::Struct
      extend T::Sig
      include Rager::Options

      const :provider, String, default: "openai"
      const :history, T::Array[Message], default: []
      const :stream, T.nilable(T::Boolean)
      const :n, T.nilable(Integer)
      const :temperature, T.nilable(Float)
      const :system_prompt, T.nilable(String)
      const :url, T.nilable(String)
      const :model, T.nilable(String)
      const :api_key, T.nilable(String)
      const :schema, T.nilable(Dry::Schema::JSON)
      const :schema_name, T.nilable(String)
      const :seed, T.nilable(Integer)
      const :http_adapter, T.nilable(Rager::Http::Adapters::Abstract)

      sig { override.returns(T::Hash[String, T.untyped]) }
      def serialize_safe
        result = serialize
        result["api_key"] = "[REDACTED]" if result.key?("api_key")
        result["schema"] = Rager::Chat::Schema.dry_schema_to_json_schema(result["schema"]) if result.key?("schema")
        result
      end

      sig { override.void }
      def validate
        if stream && schema
          raise Rager::Errors::OptionsError.new(
            invalid_keys: %w[stream schema],
            description: "You cannot use both stream and structured output"
          )
        end

        if schema && schema_name.nil?
          raise Rager::Errors::OptionsError.new(
            invalid_keys: %w[schema schema_name],
            description: "You must provide a schema name when using structured output"
          )
        end
      end
    end
  end
end
