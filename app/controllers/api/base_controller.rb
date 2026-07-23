module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :exception, unless: :api_token_request?
    before_action :authenticate_user!

    private

    def authenticate_user!
      return if current_user

      render json: { error: "Not authenticated" }, status: :unauthorized
    end

    def current_user
      @current_user ||= current_user_from_token || current_user_from_session
    end
    helper_method :current_user

    def current_user_from_token
      token = request.headers["Authorization"]&.delete_prefix("Bearer ")&.strip
      return nil if token.blank?

      User.find_by(api_token: token)
    end

    def current_user_from_session
      warden.authenticate(scope: :user)
    rescue StandardError
      nil
    end

    def api_token_request?
      request.headers["Authorization"].to_s.start_with?("Bearer ")
    end
  end
end
