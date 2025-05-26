# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "json"

module Rager
  module ImageGen
    module Providers
      class Replicate < Rager::ImageGen::Providers::Abstract
        extend T::Sig

        sig { override.params(prompt: String, options: Rager::ImageGen::Options).returns(Rager::Types::ImageGenOutput) }
        def image_gen(prompt, options)
          url = "https://api.replicate.com/v1/models/#{options.model}/predictions"
          api_key = options.api_key || ENV["REPLICATE_API_KEY"]
          raise Rager::Errors::MissingCredentialsError.new("Replicate", "REPLICATE_API_KEY") if api_key.nil?

          headers = {
            "Authorization" => "Bearer #{api_key}",
            "Content-Type" => "application/json",
            "Prefer" => "wait"
          }

          body = {
            input: {
              prompt: prompt
            }
          }
          body[:input][:seed] = options.seed unless options.seed.nil?

          request = Rager::Http::Request.new(
            url: url,
            verb: Rager::Http::Verb::Post,
            headers: headers,
            body: body.to_json
          )

          http_adapter = Rager.config.http_adapter
          response = http_adapter.make_request(request)
          response_body = T.cast(T.must(response.body), String)

          raise Rager::Errors::HttpError.new(http_adapter, response.status, response_body) unless [200, 201].include?(response.status)

          begin
            parsed = JSON.parse(response_body)
            parsed.fetch("output").first
          rescue JSON::ParserError, KeyError => e
            raise Rager::Errors::ParseError.new(e.message, response_body)
          end
        end
      end
    end
  end
end
