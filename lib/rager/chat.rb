# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    extend T::Sig

    sig do
      params(
        messages: T::Array[Rager::Chat::Message],
        options: Rager::Chat::Options
      ).returns(Rager::Types::ChatValue)
    end
    def self.chat(messages, options = Rager::Chat::Options.new)
      provider = get_provider(options.provider)
      provider.chat(messages, options)
    end

    sig do
      params(
        key: String
      ).returns(Rager::Chat::Providers::Abstract)
    end
    def self.get_provider(key)
      case key.downcase
      when "openai"
        Rager::Chat::Providers::Openai.new
      else
        raise Rager::Errors::UnknownProviderError.new(Rager::Operation::Chat, key)
      end
    end
  end
end
