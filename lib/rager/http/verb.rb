# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Http
    class Verb < T::Enum
      enums do
        Get = new("GET")
        Post = new("POST")
        Put = new("PUT")
        Patch = new("PATCH")
        Delete = new("DELETE")
        Head = new("HEAD")
        Options = new("OPTIONS")
      end
    end
  end
end
