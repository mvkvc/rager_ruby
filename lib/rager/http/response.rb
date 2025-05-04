# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Http
    class Response < T::Struct
      const :status, Integer
      const :headers, T::Hash[String, T.any(String, T::Array[String])]
      const :body, T.nilable(T.any(String, T::Enumerator[String]))
    end
  end
end
