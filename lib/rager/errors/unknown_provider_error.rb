# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Errors
    class UnknownProviderError < Rager::Error
      extend T::Sig

      sig { params(kind: Rager::Operation::Kind, key: String).void }
      def initialize(kind, key)
        super("Unknown provider #{key} for operation kind #{kind.serialize}")
      end
    end
  end
end
