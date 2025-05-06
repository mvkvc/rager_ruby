# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  class Operation
    class Kind < T::Enum
      enums do
        Chat = new("chat")
        ImageGen = new("image_gen")
        MeshGen = new("mesh_gen")
      end
    end
  end
end
