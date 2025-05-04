# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  module Chat
    class MessageContentImageType < T::Enum
      enums do
        Jpeg = new("jpeg")
        Png = new("png")
        Webp = new("webp")
      end
    end
  end
end
