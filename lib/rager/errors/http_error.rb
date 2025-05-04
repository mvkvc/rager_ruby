# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Errors
    class HttpError < Rager::Error
      extend T::Sig

      sig { params(adapter: Rager::Http::Adapters::Abstract, status: Integer, body: T.nilable(String)).void }
      def initialize(adapter, status, body)
        message = "HTTP Error #{status} using adapter #{adapter.class.name}"
        message += " -- #{body}" if body
        super(message)
      end
    end
  end
end
