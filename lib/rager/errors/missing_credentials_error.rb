# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Errors
    class MissingCredentialsError < Rager::Error
      extend T::Sig

      sig { params(provider_name: String, env_var: T.nilable(String)).void }
      def initialize(provider_name, env_var = nil)
        message = "Missing credentials for provider #{provider_name}"
        message += " -- attempted lookup with #{env_var}" if env_var
        super(message)
      end
    end
  end
end
