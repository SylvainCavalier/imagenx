require "test_helper"

module Api
  class AuthControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      # Devise's mailer resolves its mapping from the routes, which Rails only loads
      # lazily — a User.create! before the first request would otherwise blow up on
      # "Could not find a valid mapping".
      Rails.application.reload_routes_unless_loaded
      @previous_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
    end

    teardown do
      ActiveJob::Base.queue_adapter = @previous_adapter
    end

    test "registering queues the confirmation email instead of sending it inline" do
      assert_difference -> { User.count }, 1 do
        assert_enqueued_emails 1 do
          post "/api/auth/register",
               params: { email: "new@example.com", password: "password123",
                         password_confirmation: "password123" }.to_json,
               headers: { "Content-Type" => "application/json" }
        end
      end

      assert_response :created
      assert_equal "new@example.com", response.parsed_body["email"]
    end

    # Regression: an SMTP failure used to 500 the request *after* the row was committed,
    # leaving an unconfirmed account that made every retry fail with "Email has already
    # been taken". Signing up again must resend the email, not dead-end.
    test "registering again on an unconfirmed account resends the confirmation" do
      User.create!(email: "pending@example.com", password: "password123")

      assert_no_difference -> { User.count } do
        assert_enqueued_emails 1 do
          post "/api/auth/register",
               params: { email: "pending@example.com", password: "another-password",
                         password_confirmation: "another-password" }.to_json,
               headers: { "Content-Type" => "application/json" }
        end
      end

      assert_response :created
      assert_equal true, response.parsed_body["resent"]
      # The original password still owns the account — it must not be overwritten.
      assert User.find_by(email: "pending@example.com").valid_password?("password123")
    end

    test "registering on a confirmed account is still rejected" do
      User.create!(email: "taken@example.com", password: "password123").confirm

      assert_no_difference -> { User.count } do
        post "/api/auth/register",
             params: { email: "taken@example.com", password: "password123",
                       password_confirmation: "password123" }.to_json,
             headers: { "Content-Type" => "application/json" }
      end

      assert_response :unprocessable_entity
      assert_match(/already been taken/i, response.parsed_body["error"])
    end
  end
end
