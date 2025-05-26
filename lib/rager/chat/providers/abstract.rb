# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    module Providers
      class Abstract
        extend T::Sig
        extend T::Helpers
        abstract!

        sig do
          abstract.params(
            messages: T::Array[Rager::Chat::Message],
            options: Rager::Chat::Options
          ).returns(Rager::Types::ChatOutput)
        end
        def chat(messages, options)
        end
      end
    end
  end
end
