# typed: false
# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class TestImageGenReplicateProvider < Minitest::Test
  def setup
    cache_path = "./test/fixtures/http/image_gen/replicate.json"
    http_adapter = Rager::Http::Adapters::Mock.new(cache_path)

    Rager.configure do |config|
      config.http_adapter = http_adapter
    end

    @ctx = Rager::Context.new
  end

  def teardown
    Rager.reset_config!
  end

  def test_image_gen
    Async do
      r = @ctx.image_gen("A beautiful sunset over a calm ocean.", provider: "replicate")

      assert_instance_of Rager::Result, r
      assert_instance_of String, r.out
      assert_match %r{^https?://}, r.out
    end
  end
end
