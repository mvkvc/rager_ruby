# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    class MessageDelta < T::Struct
      const :index, Integer, default: 0
      const :content, String
    end
  end
end
