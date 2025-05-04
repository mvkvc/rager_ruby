# typed: false
# frozen_string_literal: true

require "async"
require "rager"

TEXT_PROMPT = ARGV[0] || "An ornate golden chalice."
puts "Prompt:"
puts TEXT_PROMPT

ctx = Rager::Context.new

Async do
  p = "Repeat this like a pirate: #{TEXT_PROMPT}"
  puts "\nAsking:"
  puts p

  r = ctx.chat(p, stream: true)

  puts "\nRaw stream output:"
  r.out.each { |d| puts d.content }

  o = r.mat.first
  puts "\nOutput:"
  puts o

  p = "Respond to this like a rival pirate: #{o}"
  puts "\nAsking:"
  puts p

  r = ctx.chat(p, stream: true)

  puts "\nRaw stream output:"
  r.out.each { |d| puts d.content }

  o = r.mat.first
  puts "\nOutput:"
  puts o
end
