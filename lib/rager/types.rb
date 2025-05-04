# typed: strict
# frozen_string_literal: true

module Rager
  module Types
    extend T::Sig

    ChatInput = T.type_alias { T.any(String, T::Array[Rager::Chat::Message]) }
    ImageGenInput = T.type_alias { String }
    MeshGenInput = T.type_alias { String }
    Input = T.type_alias {
      T.any(
        ChatInput,
        ImageGenInput,
        MeshGenInput
      )
    }

    ChatValue = T.type_alias { T.any(T::Array[String], T::Enumerator[Rager::Chat::MessageDelta]) }
    ImageGenValue = T.type_alias { String }
    MeshGenValue = T.type_alias { String }
    Value = T.type_alias {
      T.any(
        ChatValue,
        ImageGenValue,
        MeshGenValue
      )
    }

    ChatStream = T.type_alias { T::Enumerator[Rager::Chat::MessageDelta] }
    Stream = T.type_alias { ChatStream }

    ChatBuffer = T.type_alias { T::Array[Rager::Chat::MessageDelta] }
    Buffer = T.type_alias { ChatBuffer }
  end
end
