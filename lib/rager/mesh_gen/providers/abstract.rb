# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module MeshGen
    module Providers
      class Abstract
        extend T::Sig
        extend T::Helpers
        abstract!

        sig do
          abstract.params(
            image_url: String,
            options: Rager::MeshGen::Options
          ).returns(Rager::Types::MeshGenOutput)
        end
        def mesh_gen(image_url, options)
        end
      end
    end
  end
end
