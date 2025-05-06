# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module Rager
  class Operation
    extend T::Sig

    sig { returns(Rager::Options) }
    attr_reader :options

    sig do
      params(
        context_id: String,
        kind: Rager::Operation::Kind,
        input: Rager::Types::Input,
        options: Rager::Options,
        start_time: Integer,
        end_time: Integer,
        value: Rager::Types::Value,
        buffer: Rager::Types::Buffer,
        consumed: T::Boolean
      ).void
    end
    def initialize(
      context_id:,
      kind:,
      input:,
      options:,
      start_time:,
      end_time:,
      value:,
      buffer: [],
      consumed: false
    )
      @id = T.let(SecureRandom.uuid, String)
      @context_id = context_id
      @kind = kind
      @input = input
      @options = options
      @start_time = start_time
      @end_time = end_time
      @value = value
      @buffer = buffer
      @consumed = consumed
    end

    sig { returns(T::Boolean) }
    def stream?
      @value.is_a?(Enumerator)
    end

    sig { returns(Rager::Types::Value) }
    def out
      return @value unless stream?
      return @buffer.each if @consumed

      Enumerator.new do |yielder|
        T.cast(@value, Rager::Types::Stream)
          .each { |message_delta|
          @buffer << message_delta
          yielder << message_delta
        }

        @end_time = Time.now.to_i
        @consumed = true
        log
      end
    end

    sig { returns(Rager::Types::Value) }
    def mat
      return @value unless stream?

      parts = {}

      @buffer.each do |message_delta|
        parts[message_delta.index] =
          (parts[message_delta.index] || "") + message_delta.content
      end

      parts
        .sort_by { |index, _| index }
        .map { |_, content| content }
    end

    sig { returns(T.any(String, T::Array[T::Hash[String, T.untyped]])) }
    def serialize_input
      case @input
      when String
        @input
      when Array
        @input.map(&:serialize)
      end
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      {
        id: @id,
        context_id: @context_id,
        kind: @kind.serialize,
        input: serialize_input,
        options: @options.serialize_safe,
        start_time: @start_time,
        end_time: @end_time,
        value: if @consumed
                 mat
               elsif stream?
                 "[STREAM]"
               else
                 @value
               end
      }
    end

    sig { void }
    def log
      return unless Rager.config.logger

      json = to_h.to_json

      case Rager.config.logger
      when Rager::Logger::Stdout
        puts "LOG: #{json}"
      when Rager::Logger::Remote
        # TODO: Implement remote logging
      end
    end

    sig { returns(T.any(String, T::Hash[String, T.untyped])) }
    def serialize
      to_h
    end
  end
end
