module Api
  class AccountController < BaseController
    def show
      render json: { user: user_json(current_user) }
    end

    def update
      updated =
        if account_params[:current_password].present? || account_params[:email].present? || account_params[:password].present?
          current_user.assign_attributes(name: account_params[:name]) if account_params[:name].present?
          current_user.update_with_password(password_update_params)
        else
          current_user.update(name: account_params[:name])
        end

      if updated
        render json: { user: user_json(current_user) }
      else
        render json: { error: current_user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    private

    def account_params
      params.permit(:name, :email, :password, :password_confirmation, :current_password)
    end

    def password_update_params
      account_params.slice(:email, :password, :password_confirmation, :current_password)
    end

    def user_json(user)
      {
        id: user.id,
        email: user.email,
        name: user.name,
        admin: user.admin?,
        created_at: user.created_at,
        confirmed: user.confirmed?,
        credits_balance: user.credits_balance,
        subscription_status: user.subscription_status,
        subscription_plan: user.subscription_plan,
        subscription_current_period_end: user.subscription_current_period_end,
        subscription_cancel_at_period_end: user.subscription_cancel_at_period_end,
        has_stripe_customer: user.stripe_customer_id.present?
      }
    end
  end
end
