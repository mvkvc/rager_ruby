# typed: strict
# frozen_string_literal: true

require "securerandom"
require "sorbet-runtime"

module Rager
  class Context
    extend T::Sig

    sig { returns(String) }
    attr_reader :id

    sig { returns(T.nilable(String)) }
    attr_reader :hash

    sig { params(id: T.nilable(String)).void }
    def initialize(id: nil)
      @id = T.let(id || SecureRandom.uuid, String)
      @hash = T.let(lookup_git_hash, T.nilable(String))
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

      output = yield(options)

      Result.new(
        context_id: @id,
        hash: @hash,
        operation: operation,
        input: input,
        options: options,
        start_time: start_time.to_i,
        end_time: Time.now.to_i,
        output: output
      ).tap { |r| r.log }
    end

    private

    sig { returns(T.nilable(String)) }
    def lookup_git_hash
      result = `git rev-parse HEAD`
      $?.success? ? result.strip : nil
    end
  end
end
