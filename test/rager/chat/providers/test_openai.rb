# typed: false
# frozen_string_literal: true

require "dry-schema"
require "json"
require "test_helper"

class TestChatOpenaiProvider < Minitest::Test
  def setup
    cache_path = "./test/fixtures/http/chat/openai.json"
    http_adapter = Rager::Http::Adapters::Mock.new(cache_path)

    Rager.configure do |config|
      config.http_adapter = http_adapter
    end

    @ctx = Rager::Context.new
  end

  def teardown
    Rager.reset_config!
  end

  def test_chat
    Async do
      r = @ctx.chat("Tell me a joke.", provider: "openai")

      assert_instance_of Rager::Result, r
      assert_instance_of Array, r.out
      assert_equal 1, r.out.length
    end
  end

  def test_chat_streaming
    Async do
      r = @ctx.chat("Tell me a joke.", provider: "openai", stream: true)

      assert_instance_of Rager::Result, r
      assert_instance_of Enumerator, r.out

      assert_instance_of Array, r.mat
      assert_equal 1, r.mat.length
    end
  end

  def test_chat_n
    Async do
      r = @ctx.chat("Tell me a joke.", provider: "openai", n: 2)

      assert_instance_of Rager::Result, r
      assert_instance_of Array, r.out
      assert_equal 2, r.out.length
    end
  end

  def test_chat_streaming_n
    Async do
      r = @ctx.chat("Tell me a joke.", provider: "openai", stream: true, n: 2)

      assert_instance_of Rager::Result, r
      assert_instance_of Enumerator, r.out

      assert_instance_of Array, r.mat
      assert_equal 2, r.mat.length
    end
  end

  def test_simple_schema
    simple_schema = Dry::Schema.JSON do
      required(:name).filled(:string)
      required(:description).filled(:string)
    end

    prompt = "Describe a fictional character named Zorg."

    Async do
      r = @ctx.chat(prompt, schema: simple_schema, schema_name: "character", provider: "openai")

      assert_instance_of Rager::Result, r
      assert_instance_of Array, r.out
      assert_equal 1, r.out.length

      parsed_output = JSON.parse(r.out.first, symbolize_names: true)
      assert_instance_of Hash, parsed_output

      validation_result = simple_schema.call(parsed_output)
      assert validation_result.success?, "Schema validation failed: #{validation_result.errors.to_h}"
    end
  end

  def test_nested_schema
    nested_schema = Dry::Schema.JSON do
      required(:book).hash do
        required(:title).filled(:string)
        required(:author).hash do
          required(:name).filled(:string)
          required(:nationality).filled(:string)
        end
        required(:year).filled(:integer)
      end
    end

    prompt = "Provide details for the book 'Dune' by Frank Herbert, an American author, published in 1965."

    Async do
      r = @ctx.chat(prompt, schema: nested_schema, schema_name: "book_details", provider: "openai")

      assert_instance_of Rager::Result, r
      assert_instance_of Array, r.out
      assert_equal 1, r.out.length

      parsed_output = JSON.parse(r.out.first, symbolize_names: true)
      assert_instance_of Hash, parsed_output

      validation_result = nested_schema.call(parsed_output)
      assert validation_result.success?, "Schema validation failed: #{validation_result.errors.to_h}"
    end
  end

  def test_complex_schema
    complex_schema = Dry::Schema.JSON do
      required(:project_name).filled(:string)
      required(:tasks).array(:hash) do
        required(:id).filled(:integer)
        required(:description).filled(:string)
        required(:status).filled(included_in?: %w[pending in-progress completed])
        required(:assignee).hash do
          required(:name).filled(:string)
          required(:email).filled(:string)
        end
      end
    end

    prompt = "Outline tasks for project 'Alpha'. Task 1: 'Setup', assigned to Alice (alice@dev.null), status pending. Task 2: 'Develop feature X', assigned to Bob (bob@dev.null), status in-progress. Task 3: 'Testing', assigned to Alice (alice@dev.null), status pending."

    Async do
      r = @ctx.chat(prompt, schema: complex_schema, schema_name: "project_tasks", provider: "openai")

      assert_instance_of Rager::Result, r
      assert_instance_of Array, r.out
      assert_equal 1, r.out.length

      parsed_output = JSON.parse(r.out.first, symbolize_names: true)
      assert_instance_of Hash, parsed_output

      validation_result = complex_schema.call(parsed_output)
      assert validation_result.success?, "Schema validation failed: #{validation_result.errors.to_h}"
    end
  end
end
