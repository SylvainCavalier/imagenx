module Api
  class AuthController < BaseController
    skip_before_action :authenticate_user!, only: [:login, :register]

    def verify
      render json: { user: user_json(current_user) }
    end

    def login
      user = User.find_by(email: params[:email])

      if user&.valid_password?(params[:password])
        sign_in(:user, user)
        render json: { user: user_json(user) }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end

    def logout
      sign_out(:user)
      render json: { message: 'Logged out' }
    end

    def register
      user = User.new(register_params)

      if user.save
        sign_in(:user, user)
        render json: { user: user_json(user) }, status: :created
      else
        render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    private

    def register_params
      params.permit(:email, :password, :password_confirmation)
    end

    def user_json(user)
      { id: user.id, email: user.email, created_at: user.created_at }
    end
  end
end
