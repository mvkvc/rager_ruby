# typed: strict
# frozen_string_literal: true

require "dry-schema"
require "json"
require "sorbet-runtime"

Dry::Schema.load_extensions(:json_schema)

module Rager
  module Chat
    module Schema
      extend T::Sig

      sig { params(schema: Dry::Schema::JSON).returns(T::Hash[Symbol, T.untyped]) }
      def self.dry_schema_to_json_schema(schema)
        json_schema_original = schema.json_schema
        json_schema = JSON.parse(JSON.generate(json_schema_original).force_encoding("UTF-8"))

        make_strict_recursive!(json_schema)

        json_schema
      end

      sig { params(node: T.untyped).void }
      def self.make_strict_recursive!(node)
        case node
        when Hash
          %w[minLength maxLength not].each { |key| node.delete(key) }

          case node["type"]
          when "object"
            node["additionalProperties"] = false
            make_strict_recursive!(node["properties"]) if node.key?("properties")
          when "array"
            make_strict_recursive!(node["items"]) if node.key?("items")
          end

          node.each_value { |v| make_strict_recursive!(v) }
        when Array
          node.each { |item| make_strict_recursive!(item) }
        end
      end

      private_class_method :make_strict_recursive!
    end
  end
end
