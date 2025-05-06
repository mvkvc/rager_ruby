# typed: false
# frozen_string_literal: true

require "async"
require "rager"

TEXT_PROMPT = ARGV[0] || "An ornate golden chalice."
puts "Prompt:"
puts TEXT_PROMPT

ctx = Rager::Context.new

Async do
  op = ctx.image_gen(TEXT_PROMPT)

  image_url = op.out
  puts "\nImage URL:"
  puts image_url

  op = ctx.mesh_gen(image_url)

  mesh_url = op.out
  puts "\nMesh URL:"
  puts mesh_url
end
