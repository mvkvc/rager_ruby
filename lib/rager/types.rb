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

    ChatStream = T.type_alias { T::Enumerator[Rager::Chat::MessageDelta] }
    Stream = T.type_alias { ChatStream }

    ChatBuffer = T.type_alias { T::Array[Rager::Chat::MessageDelta] }
    Buffer = T.type_alias { ChatBuffer }

    ChatOutput = T.type_alias { T.any(T::Array[String], ChatStream) }
    ImageGenOutput = T.type_alias { String }
    MeshGenOutput = T.type_alias { String }
    Output = T.type_alias {
      T.any(
        ChatOutput,
        ImageGenOutput,
        MeshGenOutput
      )
    }

    ChatNonStreamOutput = T.type_alias { T::Array[String] }
    NonStreamOutput = T.type_alias {
      T.any(
        ChatNonStreamOutput,
        ImageGenOutput,
        MeshGenOutput
      )
    }
  end
end
