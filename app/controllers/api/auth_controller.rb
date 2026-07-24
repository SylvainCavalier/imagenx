module Api
  class AuthController < BaseController
    skip_before_action :authenticate_user!,
      only: [:login, :register, :confirm, :resend_confirmation, :forgot_password, :reset_password]

    # timestamp_enabled: false — the gem's timestamp check relies on a session value set by
    # its server-rendered form helper, which doesn't exist in this SPA; the honeypot field
    # (params[:subtitle], sent empty by the Vue form) is the actual spam defense here.
    invisible_captcha only: [:register], timestamp_enabled: false,
      on_spam: -> { render json: { error: "Spam detected" }, status: :unprocessable_entity }

    def verify
      render json: { user: user_json(current_user) }
    end

    def login
      user = User.find_by(email: params[:email])

      if user&.valid_password?(params[:password])
        if user.confirmed?
          sign_in(:user, user)
          render json: { user: user_json(user) }
        else
          render json: { error: "Please confirm your email before signing in", unconfirmed: true }, status: :unauthorized
        end
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def logout
      sign_out(:user)
      render json: { message: "Logged out" }
    end

    def register
      user = User.new(register_params)

      if user.save
        # confirmable gates real access, so we deliberately don't sign_in here;
        # the client shows a "check your email" state instead.
        render json: { message: "Check your email to confirm your account", email: user.email }, status: :created
      else
        render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def confirm
      user = User.confirm_by_token(params[:confirmation_token])

      if user.errors.empty?
        render json: { message: "Email confirmed", user: user_json(user) }
      else
        render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    def resend_confirmation
      user = User.find_by(email: params[:email])
      user.send_confirmation_instructions if user && !user.confirmed?

      # Always a generic success message, whether or not the email exists/is
      # already confirmed, to avoid leaking account existence.
      render json: { message: "If that email exists and is unconfirmed, instructions have been resent" }
    end

    def forgot_password
      user = User.find_by(email: params[:email])
      user&.send_reset_password_instructions

      render json: { message: "If that email exists, reset instructions have been sent" }
    end

    def reset_password
      user = User.reset_password_by_token(
        reset_password_token: params[:reset_password_token],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      )

      if user.errors.empty?
        render json: { message: "Password updated. You can now sign in." }
      else
        render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    private

    def register_params
      params.permit(:email, :password, :password_confirmation)
    end

    def user_json(user)
      {
        id: user.id,
        email: user.email,
        created_at: user.created_at,
        confirmed: user.confirmed?,
        credits_balance: user.credits_balance
      }
    end
  end
end
