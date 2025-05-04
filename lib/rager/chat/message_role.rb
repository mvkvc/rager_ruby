# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    class MessageRole < T::Enum
      enums do
        User = new("user")
        Assistant = new("assistant")
        System = new("system")
      end
    end
  end
end
