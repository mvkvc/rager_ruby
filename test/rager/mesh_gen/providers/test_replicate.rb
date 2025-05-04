# typed: false
# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class TestMeshGenReplicateProvider < Minitest::Test
  def setup
    cache_path = "./test/fixtures/http/mesh_gen/replicate.json"
    http_adapter = Rager::Http::Adapters::Mock.new(cache_path)

    Rager.configure do |config|
      config.http_adapter = http_adapter
    end

    @ctx = Rager::Context.new
  end

  def teardown
    Rager.reset_config!
  end

  def test_mesh_gen
    Async do
      r = @ctx.image_gen("An ornate golden chalice.", provider: "replicate")

      assert_instance_of Rager::Result, r
      assert_instance_of String, r.out
      assert_match %r{^https?://}, r.out

      r = @ctx.mesh_gen(r.out, provider: "replicate")

      assert_instance_of Rager::Result, r
      assert_instance_of String, r.out
      assert_match %r{^https?://}, r.out
    end
  end
end
