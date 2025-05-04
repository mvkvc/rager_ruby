# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    class MessageContent < T::Struct
      const :type, MessageContentType, default: MessageContentType::Text
      const :image_type, T.nilable(MessageContentImageType)
      const :content, String
    end
  end
end
