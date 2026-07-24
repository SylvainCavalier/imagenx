class WebhooksController < ApplicationController
  protect_from_forgery with: :null_session

  def stripe
    payload = request.body.read
    sig_header = request.headers["Stripe-Signature"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SECRET"))
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event)
    when "invoice.payment_succeeded"
      handle_invoice_payment_succeeded(event)
    when "customer.subscription.updated"
      handle_subscription_updated(event)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event)
    end

    head :ok
  end

  private

  # Wraps the idempotency guard + side effect in one transaction: recording the
  # Stripe event ID is what makes retried webhook deliveries a no-op (unique index
  # on stripe_event_id raises RecordInvalid (validation) in the common case, or
  # RecordNotUnique (DB constraint) if two deliveries race past the validation's
  # own check — both are caught below, nothing reprocessed either way).
  def with_idempotency(event)
    ActiveRecord::Base.transaction do
      StripeEvent.create!(stripe_event_id: event.id, event_type: event.type)
      yield
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    nil
  end

  def handle_checkout_completed(event)
    session = event.data.object

    with_idempotency(event) do
      if session.mode == "payment"
        user = User.find_by(id: session.metadata["user_id"])
        next unless user

        user.add_credits!(
          session.metadata["credits_amount"].to_i,
          reason: "topup_purchase",
          stripe_event_id: event.id
        )
      elsif session.mode == "subscription"
        user = User.find_by(stripe_customer_id: session.customer)
        next unless user

        user.update!(stripe_subscription_id: session.subscription)
      end
    end
  end

  def handle_invoice_payment_succeeded(event)
    invoice = event.data.object
    return if invoice.subscription.blank?

    with_idempotency(event) do
      user = User.find_by(stripe_customer_id: invoice.customer)
      next unless user

      period_end = invoice.lines.data.first&.period&.end
      user.update!(subscription_current_period_end: Time.zone.at(period_end)) if period_end

      user.add_credits!(600, reason: "subscription_grant", stripe_event_id: event.id)
    end
  end

  def handle_subscription_updated(event)
    subscription = event.data.object

    with_idempotency(event) do
      user = User.find_by(stripe_customer_id: subscription.customer)
      next unless user

      user.update!(
        stripe_subscription_id: subscription.id,
        subscription_status: subscription.status,
        subscription_plan: subscription.items.data.first&.price&.lookup_key,
        subscription_current_period_end: Time.zone.at(subscription.current_period_end),
        subscription_cancel_at_period_end: subscription.cancel_at_period_end
      )
    end
  end

  def handle_subscription_deleted(event)
    subscription = event.data.object

    with_idempotency(event) do
      user = User.find_by(stripe_customer_id: subscription.customer)
      next unless user

      user.update!(subscription_status: "canceled", subscription_cancel_at_period_end: false)
    end
  end
end
