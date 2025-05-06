# typed: strict
# frozen_string_literal: true

require "securerandom"
require "sorbet-runtime"

module Rager
  class Context
    extend T::Sig

    sig { void }
    def initialize
      @id = T.let(SecureRandom.uuid, String)
    end

    sig do
      params(
        messages: T.any(String, T::Array[Rager::Chat::Message]),
        kwargs: T.untyped
      ).returns(Rager::Operation)
    end
    def chat(messages, **kwargs)
      if messages.is_a?(String)
        messages = [
          Rager::Chat::Message.new(
            role: Rager::Chat::MessageRole::User,
            content: messages
          )
        ]
      end

      execute(
        Rager::Operation::Kind::Chat,
        Rager::Chat::Options,
        kwargs,
        messages
      ) { |options| Chat.chat(messages, options) }
    end

    sig do
      params(
        prompt: String,
        kwargs: T.untyped
      ).returns(Rager::Operation)
    end
    def image_gen(prompt, **kwargs)
      execute(
        Rager::Operation::Kind::ImageGen,
        Rager::ImageGen::Options,
        kwargs,
        prompt
      ) { |options| ImageGen.image_gen(prompt, options) }
    end

    sig do
      params(
        prompt: String,
        kwargs: T.untyped
      ).returns(Rager::Operation)
    end
    def mesh_gen(prompt, **kwargs)
      execute(
        Rager::Operation::Kind::MeshGen,
        Rager::MeshGen::Options,
        kwargs,
        prompt
      ) { |options| MeshGen.mesh_gen(prompt, options) }
    end

    private

    sig do
      params(
        kind: Rager::Operation::Kind,
        options_struct: T::Class[Rager::Options],
        kwargs: T.untyped,
        input: T.any(String, T::Array[Rager::Chat::Message]),
        block: T.proc.params(options: T.untyped).returns(T.untyped)
      ).returns(Rager::Operation)
    end
    def execute(kind, options_struct, kwargs, input, &block)
      options = options_struct.new(**kwargs)
      options.validate
      start_time = Time.now

      value = yield(options)

      Operation.new(
        context_id: @id,
        kind: kind,
        input: input,
        options: options,
        start_time: start_time.to_i,
        end_time: Time.now.to_i,
        value: value
      ).tap { |r| r.log }
    end
  end
end
