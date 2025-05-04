# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    class Message < T::Struct
      const :role, MessageRole
      const :content, T.any(String, T::Array[MessageContent])
    end
  end
end
