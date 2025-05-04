# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module ImageGen
    module Providers
      class Abstract
        extend T::Sig
        extend T::Helpers
        abstract!

        sig do
          abstract.params(
            prompt: String,
            options: Rager::ImageGen::Options
          ).returns(Rager::Types::ImageGenValue)
        end
        def image_gen(prompt, options)
        end
      end
    end
  end
end
