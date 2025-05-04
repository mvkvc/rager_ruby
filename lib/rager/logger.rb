# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  class Logger < T::Enum
    enums do
      Stdout = new("stdout")
      Remote = new("remote")
    end
  end
end
