# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module MeshGen
    extend T::Sig

    sig do
      params(
        image_url: String,
        options: Rager::MeshGen::Options
      ).returns(Rager::Types::MeshGenValue)
    end
    def self.mesh_gen(image_url, options = Rager::MeshGen::Options.new)
      provider = get_provider(options.provider)
      provider.mesh_gen(image_url, options)
    end

    sig { params(key: String).returns(Rager::MeshGen::Providers::Abstract) }
    def self.get_provider(key)
      case key.downcase
      when "replicate"
        Rager::MeshGen::Providers::Replicate.new
      else
        raise Rager::Errors::UnknownProviderError.new(Rager::Operation::Kind::MeshGen, key)
      end
    end
  end
end
