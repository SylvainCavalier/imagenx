# == Schema Information
#
# Table name: users
#
#  id                                :bigint           not null, primary key
#  admin                             :boolean          default(FALSE), not null
#  api_token                         :string
#  confirmation_sent_at              :datetime
#  confirmation_token                :string
#  confirmed_at                      :datetime
#  credits_balance                   :integer          default(0), not null
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :string
#  email                             :string           default(""), not null
#  encrypted_password                :string           default(""), not null
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :string
#  name                              :string
#  remember_created_at               :datetime
#  reset_password_sent_at            :datetime
#  reset_password_token              :string
#  sign_in_count                     :integer          default(0), not null
#  subscription_cancel_at_period_end :boolean          default(FALSE), not null
#  subscription_current_period_end   :datetime
#  subscription_plan                 :string
#  subscription_status               :string
#  unconfirmed_email                 :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  stripe_customer_id                :string
#  stripe_subscription_id            :string
#
# Indexes
#
#  index_users_on_admin                   (admin)
#  index_users_on_api_token               (api_token) UNIQUE
#  index_users_on_confirmation_token      (confirmation_token) UNIQUE
#  index_users_on_email                   (email) UNIQUE
#  index_users_on_reset_password_token    (reset_password_token) UNIQUE
#  index_users_on_stripe_customer_id      (stripe_customer_id) UNIQUE
#  index_users_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#
class User < ApplicationRecord
  TRIAL_CREDITS = 80
  GENERATION_COST_PER_IMAGE = 8

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  has_secure_token :api_token

  has_many :generation_batches, dependent: :destroy
  has_many :image_folders, dependent: :destroy
  has_many :prompt_presets, dependent: :destroy
  has_many :credit_transactions, dependent: :destroy
  has_many :support_tickets, dependent: :destroy

  scope :paid, -> { where(subscription_status: %w[active trialing past_due]) }
  scope :free, -> { where(subscription_status: [nil, "canceled"]) }

  after_create :grant_trial_credits

  # Credits an amount to this user and records it in the ledger, atomically.
  # Used for trial grants, Stripe top-ups/subscription renewals, and per-item refunds.
  def add_credits!(amount, reason:, source: nil, stripe_event_id: nil, metadata: {})
    raise ArgumentError, "amount must be positive" unless amount.positive?

    transaction do
      lock!
      increment!(:credits_balance, amount)
      credit_transactions.create!(
        amount: amount,
        balance_after: credits_balance,
        reason: reason,
        source: source,
        stripe_event_id: stripe_event_id,
        metadata: metadata
      )
    end
  end

  # Atomically debits `amount` credits from user `user_id` only if the balance
  # covers it, via a single conditional UPDATE (no read-then-write race window).
  # Returns true if the debit happened, false if the balance was insufficient.
  def self.debit_credits(user_id, amount)
    where(id: user_id)
      .where(credits_balance: amount..)
      .update_all(["credits_balance = credits_balance - ?", amount]) == 1
  end

  # Devise delivers its emails inline, from an `after_commit` hook on create. An SMTP
  # failure therefore raised *after* the user row was committed: the request 500'd while
  # the account existed, and the retry hit "Email has already been taken". Queueing the
  # delivery keeps signup atomic from the user's point of view and lets the job retry.
  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  private

  def grant_trial_credits
    add_credits!(TRIAL_CREDITS, reason: "trial_grant")
  end
end
