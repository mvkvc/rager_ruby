# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    class MessageContentType < T::Enum
      enums do
        Text = new("text")
        ImageUrl = new("image_url")
        ImageBase64 = new("image_base64")
      end
    end
  end
end
