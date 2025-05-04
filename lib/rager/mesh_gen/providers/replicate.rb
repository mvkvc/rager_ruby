# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "json"

module Rager
  module MeshGen
    module Providers
      class Replicate < Rager::MeshGen::Providers::Abstract
        extend T::Sig

        sig { override.params(image_url: String, options: Rager::MeshGen::Options).returns(Rager::Types::MeshGenValue) }
        def mesh_gen(image_url, options)
          api_key = options.api_key || ENV["REPLICATE_API_KEY"]
          raise Rager::Errors::MissingCredentialsError.new("Replicate", "REPLICATE_API_KEY") if api_key.nil?

          headers = {
            "Authorization" => "Bearer #{api_key}",
            "Content-Type" => "application/json",
            "Prefer" => "wait"
          }

          body = {
            version: options.version,
            input: {
              images: [image_url],
              texture_size: 2048,
              mesh_simplify: 0.9,
              generate_model: true,
              save_gaussian_ply: true,
              ss_sampling_steps: 38
            }
          }
          body[:input][:seed] = options.seed unless options.seed.nil?

          request = Rager::Http::Request.new(
            url: "https://api.replicate.com/v1/predictions",
            verb: Rager::Http::Verb::Post,
            headers: headers,
            body: body.to_json
          )

          response = Rager.config.http_adapter.make_request(request)
          response_body = T.cast(T.must(response.body), String)

          raise Rager::Errors::HttpError.new(Rager.config.http_adapter, response.status, response_body) unless [200,
            201, 202].include?(response.status)

          begin
            json = JSON.parse(response_body)
            model_file = json.dig("output", "model_file")
            model_file || json.fetch("urls").fetch("get")
          rescue JSON::ParserError, KeyError => e
            raise Rager::Errors::ParseError.new(e.message, response_body)
          end
        end
      end
    end
  end
end
