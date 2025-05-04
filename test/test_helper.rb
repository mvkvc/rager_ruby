# typed: false
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "warning"

Gem.path.each do |path|
  Warning.ignore(//, path)
end

require "rager"
require "minitest/autorun"
