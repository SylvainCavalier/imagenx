module Api
  module Admin
    class BaseController < Api::BaseController
      before_action :authorize_admin!

      private

      def authorize_admin!
        render json: { error: "Forbidden" }, status: :forbidden unless current_user&.admin?
      end
    end
  end
end
