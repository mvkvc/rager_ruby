# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Errors
    class UnknownProviderError < Rager::Error
      extend T::Sig

      sig { params(operation: Rager::Operation, key: String).void }
      def initialize(operation, key)
        super("Unknown provider #{key} for operation #{operation.serialize}")
      end
    end
  end
end
