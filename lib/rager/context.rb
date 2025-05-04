# typed: strict
# frozen_string_literal: true

require "securerandom"
require "sorbet-runtime"

module Rager
  class Context
    extend T::Sig

    sig {
      params(
        id: T.nilable(String)
      ).void
    }
    def initialize(id: nil)
      @id = T.let(id || SecureRandom.uuid, String)
    end

    sig do
      params(
        messages: T.any(String, T::Array[Rager::Chat::Message]),
        kwargs: T.untyped
      ).returns(Rager::Result)
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
        Rager::Operation::Chat,
        Rager::Chat::Options,
        kwargs,
        messages
      ) { |options| Chat.chat(messages, options) }
    end

    sig do
      params(
        prompt: String,
        kwargs: T.untyped
      ).returns(Rager::Result)
    end
    def image_gen(prompt, **kwargs)
      execute(
        Rager::Operation::ImageGen,
        Rager::ImageGen::Options,
        kwargs,
        prompt
      ) { |options| ImageGen.image_gen(prompt, options) }
    end

    sig do
      params(
        prompt: String,
        kwargs: T.untyped
      ).returns(Rager::Result)
    end
    def mesh_gen(prompt, **kwargs)
      execute(
        Rager::Operation::MeshGen,
        Rager::MeshGen::Options,
        kwargs,
        prompt
      ) { |options| MeshGen.mesh_gen(prompt, options) }
    end

    private

    sig do
      params(
        operation: Rager::Operation,
        options_struct: T::Class[Rager::Options],
        kwargs: T.untyped,
        input: T.any(String, T::Array[Rager::Chat::Message]),
        block: T.proc.params(options: T.untyped).returns(T.untyped)
      ).returns(Rager::Result)
    end
    def execute(operation, options_struct, kwargs, input, &block)
      options = options_struct.new(**kwargs)
      options.validate
      start_time = Time.now

      value = yield(options)

      Result.new(
        context_id: @id,
        operation: operation,
        input: input,
        options: options,
        start_time: start_time.to_i,
        end_time: Time.now.to_i,
        value: value
      ).tap { |r| r.log }
    end
  end
end
