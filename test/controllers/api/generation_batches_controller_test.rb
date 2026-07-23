require "test_helper"

module Api
  class GenerationBatchesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = User.create!(email: "agent@example.com", password: "password123")
    end

    test "creates a batch with a valid bearer token, no session or CSRF needed" do
      post "/api/generation_batches",
           params: { main_prompt: "cinematic lighting", aspect_ratio: "1:1", items: [{ prompt: "a fox" }] }.to_json,
           headers: { "Authorization" => "Bearer #{@user.api_token}", "Content-Type" => "application/json" }

      assert_response :created
      body = response.parsed_body
      assert_equal "cinematic lighting", body["main_prompt"]
      assert_equal 1, body["items"].length
    end

    test "rejects an invalid bearer token" do
      post "/api/generation_batches",
           params: { main_prompt: "cinematic lighting", items: [{ prompt: "a fox" }] }.to_json,
           headers: { "Authorization" => "Bearer not-a-real-token", "Content-Type" => "application/json" }

      assert_response :unauthorized
    end

    test "rejects requests with no auth at all" do
      post "/api/generation_batches",
           params: { main_prompt: "cinematic lighting", items: [{ prompt: "a fox" }] }.to_json,
           headers: { "Content-Type" => "application/json" }

      assert_response :unauthorized
    end
  end
end
