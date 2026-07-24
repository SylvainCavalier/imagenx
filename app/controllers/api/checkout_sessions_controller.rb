module Api
  class CheckoutSessionsController < BaseController
    TOPUP_PACKS = {
      "topup_300" => 300,
      "topup_500" => 500,
      "topup_1000" => 1000,
      "topup_2000" => 2000
    }.freeze
    SUBSCRIPTION_KEY = "subscription_monthly"

    def create
      pack = params[:pack]

      unless TOPUP_PACKS.key?(pack) || pack == SUBSCRIPTION_KEY
        return render json: { error: "Unknown pack" }, status: :unprocessable_entity
      end

      price = Stripe::Price.list(lookup_keys: [pack], active: true).data.first
      unless price
        return render json: { error: "Pack not available" }, status: :unprocessable_entity
      end

      ensure_stripe_customer!

      session = Stripe::Checkout::Session.create(
        customer: current_user.stripe_customer_id,
        mode: pack == SUBSCRIPTION_KEY ? "subscription" : "payment",
        line_items: [{ price: price.id, quantity: 1 }],
        metadata: pack == SUBSCRIPTION_KEY ? {} : { user_id: current_user.id, credits_amount: TOPUP_PACKS[pack] },
        success_url: "#{request.base_url}/app/account?checkout=success",
        cancel_url: "#{request.base_url}/app/account?checkout=cancel"
      )

      render json: { url: session.url }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def ensure_stripe_customer!
      return if current_user.stripe_customer_id.present?

      customer = Stripe::Customer.create(
        email: current_user.email,
        metadata: { user_id: current_user.id }
      )
      current_user.update!(stripe_customer_id: customer.id)
    end
  end
end
