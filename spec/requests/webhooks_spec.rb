require 'rails_helper'

RSpec.describe 'Webhooks::Stripe', type: :request do
  let(:webhook_secret) { 'whsec_test_secret' }

  before do
    ENV['STRIPE_WEBHOOK_SECRET'] = webhook_secret
  end

  def signed_post(payload_json)
    timestamp = Time.now
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload_json, webhook_secret)
    header = Stripe::Webhook::Signature.generate_header(timestamp, signature)

    post '/webhooks/stripe',
      params: payload_json,
      headers: { 'CONTENT_TYPE' => 'application/json', 'Stripe-Signature' => header }
  end

  def checkout_completed_payload(event_id:, user_id:, credits_amount: 300)
    {
      id: event_id,
      object: 'event',
      type: 'checkout.session.completed',
      data: {
        object: {
          id: 'cs_test_1',
          object: 'checkout.session',
          mode: 'payment',
          customer: 'cus_test_1',
          subscription: nil,
          metadata: { user_id: user_id.to_s, credits_amount: credits_amount.to_s }
        }
      }
    }.to_json
  end

  describe 'signature verification' do
    it 'rejects a request with an invalid signature' do
      payload = checkout_completed_payload(event_id: 'evt_bad', user_id: 1)

      post '/webhooks/stripe',
        params: payload,
        headers: { 'CONTENT_TYPE' => 'application/json', 'Stripe-Signature' => 't=1,v1=deadbeef' }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'checkout.session.completed (top-up)' do
    let(:user) { create(:user, :with_credits, starting_credits: 0) }

    it 'credits the user for the purchased pack' do
      payload = checkout_completed_payload(event_id: 'evt_topup_1', user_id: user.id, credits_amount: 300)

      expect {
        signed_post(payload)
      }.to change { user.reload.credits_balance }.by(300)

      expect(response).to have_http_status(:ok)
      expect(StripeEvent.find_by(stripe_event_id: 'evt_topup_1')).to be_present

      transaction = CreditTransaction.find_by(stripe_event_id: 'evt_topup_1')
      expect(transaction.reason).to eq('topup_purchase')
      expect(transaction.amount).to eq(300)
    end

    it 'does not double-credit when the same event is replayed' do
      payload = checkout_completed_payload(event_id: 'evt_topup_replay', user_id: user.id, credits_amount: 300)

      signed_post(payload)
      expect(user.reload.credits_balance).to eq(300)

      expect {
        signed_post(payload)
      }.not_to change { user.reload.credits_balance }

      expect(response).to have_http_status(:ok)
      expect(StripeEvent.where(stripe_event_id: 'evt_topup_replay').count).to eq(1)
      expect(CreditTransaction.where(stripe_event_id: 'evt_topup_replay').count).to eq(1)
    end
  end

  describe 'an unrecognized event type' do
    it 'acknowledges without side effects' do
      payload = { id: 'evt_unknown', object: 'event', type: 'customer.created', data: { object: {} } }.to_json

      signed_post(payload)

      expect(response).to have_http_status(:ok)
      expect(StripeEvent.find_by(stripe_event_id: 'evt_unknown')).to be_nil
    end
  end
end
