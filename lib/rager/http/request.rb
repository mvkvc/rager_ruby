# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Http
    class Request < T::Struct
      const :url, String
      const :verb, Rager::Http::Verb, default: Rager::Http::Verb::Get
      const :headers, T::Hash[String, String]
      const :body, T.nilable(String)
    end
  end
end
