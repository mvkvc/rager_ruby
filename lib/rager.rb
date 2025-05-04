# typed: strict
# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require "sorbet-runtime"

module Rager
  extend T::Sig

  ConfigBlock = T.type_alias do
    T.proc.params(config: Config).void
  end

  @config = T.let(nil, T.nilable(Rager::Config))

  sig { returns(Config) }
  def self.config
    @config ||= Config.new
  end

  sig { params(block: ConfigBlock).void }
  def self.configure(&block)
    yield(config)
  end

  sig { void }
  def self.reset_config!
    @config = Config.new
  end
end

loader.eager_load
