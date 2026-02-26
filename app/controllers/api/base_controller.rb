module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :exception
    before_action :authenticate_user!

    private

    def authenticate_user!
      unless current_user
        render json: { error: 'Not authenticated' }, status: :unauthorized
      end
    end

    def current_user
      @current_user ||= begin
        warden.authenticate(scope: :user)
      rescue
        nil
      end
    end
    helper_method :current_user
  end
end
