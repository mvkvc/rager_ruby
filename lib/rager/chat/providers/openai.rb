# typed: strict
# frozen_string_literal: true

require "json"
require "sorbet-runtime"

module Rager
  module Chat
    module Providers
      class Openai < Rager::Chat::Providers::Abstract
        extend T::Sig

        OpenaiMessages = T.type_alias { T::Array[T::Hash[String, T.any(String, T::Array[T.untyped])]] }

        sig do
          override.params(
            messages: T::Array[Rager::Chat::Message],
            options: Rager::Chat::Options
          ).returns(Rager::Types::ChatOutput)
        end
        def chat(messages, options)
          api_key = options.api_key || ENV["OPENAI_API_KEY"]
          raise Rager::Errors::MissingCredentialsError.new("OpenAI", "OPENAI_API_KEY") if api_key.nil?

          url = options.url || ENV["OPENAI_URL"] || "https://api.openai.com/v1/chat/completions"
          model = options.model || "gpt-4o"

          openai_messages = build_openai_messages(messages, options.history, options.system_prompt)

          headers = {
            "Content-Type" => "application/json"
          }
          headers["Authorization"] = "Bearer #{api_key}" if api_key

          body = {
            model: model,
            messages: openai_messages
          }
          body[:temperature] = options.temperature unless options.temperature.nil?
          body[:n] = options.n unless options.n.nil?
          body[:stream] = options.stream unless options.stream.nil?
          body[:seed] = options.seed unless options.seed.nil?

          if options.schema && options.schema_name
            body[:response_format] = {
              type: "json_schema",
              json_schema: {
                name: T.must(options.schema_name).downcase,
                strict: true,
                schema: Rager::Chat::Schema.dry_schema_to_json_schema(T.must(options.schema))
              }
            }
          end

          request = Rager::Http::Request.new(
            verb: Rager::Http::Verb::Post,
            url: url,
            headers: headers,
            body: body.to_json
          )

          http_adapter = Rager.config.http_adapter
          response = http_adapter.make_request(request)
          response_body = T.must(response.body)

          if response.status != 200
            raise Rager::Errors::HttpError.new(
              http_adapter,
              response.status,
              T.cast(response_body, String)
            )
          end

          case response_body
          when String
            parse_non_stream_body(response_body)
          when Enumerator
            create_message_delta_stream(response_body)
          end
        end

        sig do
          params(
            messages: T::Array[Rager::Chat::Message],
            history: T::Array[Rager::Chat::Message],
            system_prompt: T.nilable(String)
          ).returns(OpenaiMessages)
        end
        def build_openai_messages(messages, history, system_prompt)
          result = T.let([], OpenaiMessages)

          if history.empty? && system_prompt && !system_prompt.empty?
            result << {"role" => "system",
                        "content" => system_prompt}
          end

          history.each do |msg|
            role_str = msg.role.is_a?(String) ? msg.role : msg.role.serialize
            result << {"role" => role_str, "content" => msg.content}
          end

          messages.each do |message|
            role_str = message.role.is_a?(String) ? message.role : message.role.serialize
            content = message.content

            if content.is_a?(String)
              result << {"role" => role_str, "content" => content}
            elsif content.is_a?(Array)
              formatted_content = content.map do |item|
                item_type = item.type
                case item_type
                when Rager::Chat::MessageContentType::Text
                  {"type" => "text", "text" => item.content}
                when Rager::Chat::MessageContentType::ImageUrl
                  {"type" => "image_url", "image_url" => {"url" => item.content}}
                when Rager::Chat::MessageContentType::ImageBase64
                  image_type = T.must(item.image_type)
                  image_mime_type = case image_type
                  when Rager::Chat::MessageContentImageType::Jpeg then "image/jpeg"
                  when Rager::Chat::MessageContentImageType::Png then "image/png"
                  when Rager::Chat::MessageContentImageType::Webp then "image/webp"
                  end
                  data_uri = "data:#{image_mime_type};base64,#{item.content}"
                  {"type" => "image_url", "image_url" => {"url" => data_uri}}
                end
              end
              result << {"role" => role_str, "content" => formatted_content}
            end
          end

          result
        end

        sig { params(body: String).returns(T::Array[String]) }
        def parse_non_stream_body(body)
          messages = T.let([], T::Array[String])

          begin
            response_data = JSON.parse(body)
            if response_data.key?("choices") && response_data["choices"].is_a?(Array)
              response_data["choices"].each do |choice|
                text = choice.dig("message", "content").to_s
                messages << text unless text.empty?
              end
            end
          rescue JSON::ParserError
            raise Rager::Errors::ParseError.new(
              "OpenAI response body is not valid JSON",
              body
            )
          end

          messages
        end

        sig { params(body: T::Enumerator[String]).returns(T::Enumerator[Rager::Chat::MessageDelta]) }
        def create_message_delta_stream(body)
          Enumerator.new do |yielder|
            buffer = +""

            process_chunk = lambda do |chunk|
              buffer << chunk
              pattern = /\Adata: (.*?)\n\n|\Adata: (.*?)\n/
              while (event_match = buffer.match(pattern))
                full_event = T.must(event_match[0])
                data_line = event_match[1] || event_match[2]

                buffer.delete_prefix!(full_event)

                next if data_line.nil? || data_line.strip.empty?
                next if data_line.strip == "[DONE]"

                begin
                  data = JSON.parse(data_line)
                  if data.key?("choices") && data["choices"].is_a?(Array)
                    data["choices"].each do |choice|
                      choice_index = choice.dig("index") || 0
                      delta = choice.dig("delta", "content")
                      yielder << Rager::Chat::MessageDelta.new(index: choice_index, content: delta) if delta
                    end
                  end
                rescue JSON::ParserError
                  next
                end
              end
            end

            body.each(&process_chunk)

            process_chunk.call("\n") unless buffer.empty?
          end
        end
      end
    end
  end
end
