# typed: strict
# frozen_string_literal: true

require "async/http"
require "sorbet-runtime"

module Rager
  module Http
    module Adapters
      class AsyncHttp < Rager::Http::Adapters::Abstract
        extend T::Sig

        sig { void }
        def initialize
          @internet = T.let(Async::HTTP::Internet.new, Async::HTTP::Internet)
        end

        sig {
          override.params(
            request: Rager::Http::Request
          ).returns(Rager::Http::Response)
        }
        def make_request(request)
          response = @internet.call(
            request.verb.serialize,
            request.url,
            request.headers.to_a,
            request.body
          )

          body = if response.body.nil?
            nil
          elsif (response.headers["Transfer-Encoding"]&.downcase == "chunked") ||
              response.headers["content-type"]&.downcase&.include?("text/event-stream")
            body_enum(response)
          else
            response.body.read
          end

          Response.new(
            status: response.status,
            headers: response.headers.to_h,
            body: body
          )
        end

        private

        sig {
          params(
            response: Async::HTTP::Protocol::Response
          ).returns(T::Enumerator[String])
        }
        def body_enum(response)
          Enumerator.new do |yielder|
            response.body.each { |chunk| yielder << chunk.force_encoding("UTF-8") }
          ensure
            response.close
          end
        end
      end
    end
  end
end
