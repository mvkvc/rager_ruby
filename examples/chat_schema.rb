# typed: false
# frozen_string_literal: true

require "async"
require "rager"
require "json"

TEXT_PROMPT = ARGV[0] || "France"
puts "Prompt:"
puts TEXT_PROMPT

country_schema = Dry::Schema.JSON do
  required(:name).hash do
    required(:native).filled(:string)
    required(:international).filled(:string)
  end
  required(:languages).array(:string)
  required(:capital).filled(:string)
  required(:population).filled(:integer)
  required(:currency).filled(:string)
end

json_schema = Rager::Chat::Schema.dry_schema_to_json_schema(country_schema)

puts "\nJSON Schema:"
puts JSON.pretty_generate(json_schema)

ctx = Rager::Context.new

Async do
  prompt = "Give me information about #{TEXT_PROMPT}"
  puts "\nAsking:"
  puts prompt

  op = ctx.chat(prompt, schema: country_schema, schema_name: "country")

  json = JSON.parse(op.mat.first)
  puts "\nStructured output:"
  puts json

  puts "\nValidation:"
  puts country_schema.call(json).to_h
end
