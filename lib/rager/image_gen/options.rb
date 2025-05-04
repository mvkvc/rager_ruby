# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module ImageGen
    class Options < T::Struct
      extend T::Sig
      include Rager::Options

      const :provider, String, default: "replicate"
      const :model, String, default: "black-forest-labs/flux-schnell"
      const :api_key, T.nilable(String)
      const :seed, T.nilable(Integer)

      sig { override.returns(T::Hash[String, T.untyped]) }
      def serialize_safe
        result = serialize
        result["api_key"] = "[REDACTED]" if result.key?("api_key")
        result
      end

      sig { override.void }
      def validate
      end
    end
  end
end
