# frozen_string_literal: true

require_relative "lib/rager/version"

Gem::Specification.new do |spec|
  spec.name = "rager"
  spec.version = Rager::VERSION
  spec.summary = "Build continuously improving AI applications."
  spec.homepage = "https://github.com/mvkvc/rager_ruby"
  spec.license = "MIT"

  spec.authors = ["mvkvc"]
  spec.email = ["mail@mvk.vc"]

  spec.files = Dir["*.{md}", "{lib}/**/*"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "async-http", "~> 0.88.0"
  spec.add_dependency "base64", "~> 0.2.0"
  spec.add_dependency "dry-schema", "~> 1.14"
  spec.add_dependency "sorbet-runtime", "~> 0.5.12028"
  spec.add_dependency "zeitwerk", "~> 2.7"
end
