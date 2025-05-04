# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Errors
    class OptionsError < Rager::Error
      extend T::Sig

      sig { params(invalid_keys: T::Array[String], description: T.nilable(String)).void }
      def initialize(invalid_keys:, description: nil)
        message = "Invalid keys #{invalid_keys.join(", ")}"
        message += " -- #{description})" if description
        super(message)
      end
    end
  end
end
