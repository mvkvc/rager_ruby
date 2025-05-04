# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  class Config
    extend T::Sig

    sig { returns(Rager::Http::Adapters::Abstract) }
    attr_accessor :http_adapter

    sig { returns(T.nilable(Rager::Logger)) }
    attr_accessor :logger

    sig { void }
    def initialize
      @http_adapter = T.let(Rager::Http::Adapters::AsyncHttp.new, Rager::Http::Adapters::Abstract)
      @logger = T.let(nil, T.nilable(Rager::Logger))
    end
  end
end
