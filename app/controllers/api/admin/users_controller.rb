module Api
  module Admin
    class UsersController < BaseController
      def index
        scope = User.order(created_at: :desc)
        if params[:q].present?
          scope = scope.where("email ILIKE :q OR name ILIKE :q", q: "%#{params[:q]}%")
        end

        pagy, records = pagy(scope, items: params[:per_page] || 25)

        render json: {
          records: records.map { |u| user_admin_json(u) },
          pagy: { page: pagy.page, pages: pagy.pages, count: pagy.count }
        }
      end

      def create
        user = User.new(user_params)
        random_password = SecureRandom.hex(12)
        user.password = random_password
        user.password_confirmation = random_password
        user.skip_confirmation!

        if user.save
          render json: { user: user_admin_json(user) }, status: :created
        else
          render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render json: { user: user_admin_json(user) }
        else
          render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:name, :email, :admin, :credits_balance)
      end

      def user_admin_json(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          admin: user.admin?,
          confirmed: user.confirmed?,
          credits_balance: user.credits_balance,
          subscription_status: user.subscription_status,
          subscription_plan: user.subscription_plan,
          sign_in_count: user.sign_in_count,
          last_sign_in_at: user.last_sign_in_at,
          created_at: user.created_at
        }
      end
    end
  end
end
