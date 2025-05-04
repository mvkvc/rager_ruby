# typed: strict
# frozen_string_literal: true

require "fileutils"
require "json"
require "sorbet-runtime"

module Rager
  module Http
    module Adapters
      class Mock < Rager::Http::Adapters::Abstract
        extend T::Sig

        Cache = T.type_alias { T::Hash[String, T::Hash[String, T.untyped]] }

        sig do
          params(
            test_file_path: String,
            fallback_adapter: T.nilable(Rager::Http::Adapters::Abstract),
            chunk_delimiter: T.nilable(String)
          ).void
        end
        def initialize(
          test_file_path,
          fallback_adapter = nil,
          chunk_delimiter = nil
        )
          @test_file_path = T.let(test_file_path, String)
          @fallback_adapter = T.let(fallback_adapter || Rager::Http::Adapters::AsyncHttp.new, Rager::Http::Adapters::Abstract)
          @cache = T.let(load_cache, Cache)
        end

        sig { override.params(request: Rager::Http::Request).returns(Rager::Http::Response) }
        def make_request(request)
          key = request.serialize.to_json
          cached_entry = @cache[key]
          if cached_entry
            build_response_from_cache(cached_entry)
          else
            fetch_and_cache_response(request, key)
          end
        end

        sig {
          params(
            request: Rager::Http::Request,
            key: String
          ).returns(Rager::Http::Response)
        }
        def fetch_and_cache_response(request, key)
          response = @fallback_adapter.make_request(request)

          serialized_response = T.let({
            "status" => response.status,
            "headers" => response.headers
          }, T::Hash[String, T.untyped])

          if response.body.is_a?(Enumerator)
            chunks = T.let([], T::Array[String])

            T.cast(response.body, T::Enumerator[String]).each do |chunk|
              chunks << chunk
            end

            serialized_response["body"] = chunks
            serialized_response["is_stream"] = true

            response_body = Enumerator.new do |yielder|
              chunks.each { |chunk| yielder << chunk }
            end
          else
            serialized_response["body"] = response.body
            serialized_response["is_stream"] = false
            response_body = response.body
          end

          @cache[key] = serialized_response

          save_cache

          Rager::Http::Response.new(
            status: response.status,
            headers: response.headers,
            body: response_body
          )
        end

        sig {
          params(
            entry: T::Hash[String, T.untyped]
          ).returns(Rager::Http::Response)
        }
        def build_response_from_cache(entry)
          body = entry["body"]
          is_stream = entry["is_stream"] || false

          body = if is_stream
            T.cast(body, T::Array[String]).to_enum
          else
            body
          end

          Rager::Http::Response.new(
            status: T.cast(entry["status"], Integer),
            headers: T.cast(entry["headers"], T::Hash[String, String]),
            body: body
          )
        end

        sig { void }
        def create_file_if_not_exists
          FileUtils.mkdir_p(File.dirname(@test_file_path))
          File.write(@test_file_path, "{}") unless File.exist?(@test_file_path)
        end

        sig { returns(Cache) }
        def load_cache
          create_file_if_not_exists
          JSON.parse(File.read(@test_file_path, encoding: "UTF-8"))
        end

        sig { void }
        def save_cache
          current_file_content = if File.exist?(@test_file_path)
            JSON.parse(File.read(@test_file_path, encoding: "UTF-8"))
          else
            {}
          end
          output = current_file_content.merge(@cache)
          File.write(@test_file_path, output.to_json, encoding: "UTF-8")
        end
      end
    end
  end
end
