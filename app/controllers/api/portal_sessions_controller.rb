module Api
  class PortalSessionsController < BaseController
    def create
      unless current_user.stripe_customer_id.present?
        return render json: { error: "No billing account yet" }, status: :unprocessable_entity
      end

      session = Stripe::BillingPortal::Session.create(
        customer: current_user.stripe_customer_id,
        return_url: "#{request.base_url}/app/account"
      )

      render json: { url: session.url }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
