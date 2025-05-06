# typed: false
# frozen_string_literal: true

require "async"
require "rager"

TEXT_PROMPT = ARGV[0] || "An ornate golden chalice."
puts "Prompt:"
puts TEXT_PROMPT

ctx = Rager::Context.new

Async do
  prompt = "Repeat this like a pirate: #{TEXT_PROMPT}"
  puts "\nAsking:"
  puts prompt

  op = ctx.chat(prompt, stream: true)

  puts "\nRaw stream output:"
  op.out.each { |d| puts d.content }
  output = op.mat.first
  puts "\nOutput:"
  puts output

  prompt = "Respond to this like a rival pirate: #{output}"
  puts "\nAsking:"
  puts prompt

  op = ctx.chat(prompt, stream: true)

  puts "\nRaw stream output:"
  op.out.each { |d| puts d.content }

  output = op.mat.first
  puts "\nOutput:"
  puts output
end
