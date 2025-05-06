# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module ImageGen
    extend T::Sig

    sig do
      params(
        prompt: String,
        options: Rager::ImageGen::Options
      ).returns(Rager::Types::ImageGenValue)
    end
    def self.image_gen(prompt, options = Rager::ImageGen::Options.new)
      provider = get_provider(options.provider)
      provider.image_gen(prompt, options)
    end

    sig { params(key: String).returns(Rager::ImageGen::Providers::Abstract) }
    def self.get_provider(key)
      case key.downcase
      when "replicate"
        Rager::ImageGen::Providers::Replicate.new
      else
        raise Rager::Errors::UnknownProviderError.new(Rager::Operation::Kind::ImageGen, key)
      end
    end
  end
end
