# typed: strict
# frozen_string_literal: true

require "json"
require "securerandom"
require "sorbet-runtime"

module Rager
  class Result
    extend T::Sig

    sig { returns(Rager::Operation) }
    attr_reader :operation

    sig { returns(Rager::Options) }
    attr_reader :options

    sig { returns(Rager::Types::Input) }
    attr_reader :input

    sig { returns(Integer) }
    attr_reader :start_time

    sig { returns(Integer) }
    attr_reader :end_time

    sig { returns(T.nilable(String)) }
    attr_reader :result_id

    sig { returns(T.nilable(String)) }
    attr_reader :context_id

    sig { returns(T.nilable(String)) }
    attr_reader :hash

    sig do
      params(
        operation: Rager::Operation,
        options: Rager::Options,
        input: Rager::Types::Input,
        output: Rager::Types::Output,
        start_time: Integer,
        end_time: Integer,
        context_id: T.nilable(String),
        hash: T.nilable(String)
      ).void
    end
    def initialize(
      operation:,
      options:,
      input:,
      output:,
      start_time:,
      end_time:,
      context_id: nil,
      hash: nil
    )
      @operation = operation
      @options = options
      @input = input
      @output = output
      @start_time = start_time
      @end_time = end_time
      @stream = T.let(nil, T.nilable(Rager::Types::Stream))
      @buffer = T.let([], Rager::Types::Buffer)
      @consumed = T.let(false, T::Boolean)
      @result_id = T.let(SecureRandom.uuid, T.nilable(String))
      @context_id = T.let(context_id, T.nilable(String))
      @hash = T.let(hash, T.nilable(String))
    end

    sig { returns(T::Boolean) }
    def stream?
      @output.is_a?(Enumerator)
    end

    sig { returns(Rager::Types::Output) }
    def out
      return @output unless stream?
      return @buffer.each if @consumed

      log

      @stream = Enumerator.new do |yielder|
        T.cast(@output, Rager::Types::Stream)
          .each { |message_delta|
          @buffer << message_delta
          yielder << message_delta
        }

        @consumed = true
        @end_time = Time.now.to_i

        log
      end

      @stream
    end

    sig { returns(Rager::Types::NonStreamOutput) }
    def mat
      return T.cast(@output, Rager::Types::NonStreamOutput) unless stream?

      if !@consumed
        T.cast(out, Rager::Types::Stream).each { |_| }
      end

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

    sig { returns(Rager::Types::NonStreamOutput) }
    def serialize_output
      if @consumed
        mat
      elsif stream?
        "[STREAM]"
      else
        T.cast(@output, Rager::Types::NonStreamOutput)
      end
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      {
        operation: @operation.serialize,
        options: @options.serialize_safe,
        input: serialize_input,
        output: if @consumed
                  mat
                elsif stream?
                  "[STREAM]"
                else
                  @output
                end,
        start_time: @start_time,
        end_time: @end_time,
        result_id: @result_id,
        context_id: @context_id,
        hash: @hash
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
        http_adapter = Rager.config.http_adapter
        url = Rager.config.url
        api_key = Rager.config.api_key

        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{api_key}"
        }

        if url && api_key
          request = Rager::Http::Request.new(
            url: url,
            verb: Rager::Http::Verb::Post,
            headers: headers,
            body: json
          )

          response = http_adapter.make_request(request)

          unless response.status >= 200 && response.status < 300
            warn "Remote log failed: \\#{response.status} \\#{response.body}"
          end
        end
      end
    end
  end
end
