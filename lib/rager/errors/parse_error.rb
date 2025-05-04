# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Errors
    class ParseError < Rager::Error
      extend T::Sig

      sig { params(description: String, body: T.nilable(String)).void }
      def initialize(description, body = nil)
        message = description
        message += " -- #{body}" if body
        super(message)
      end
    end
  end
end
