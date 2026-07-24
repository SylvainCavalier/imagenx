# == Schema Information
#
# Table name: credit_transactions
#
#  id              :bigint           not null, primary key
#  amount          :integer          not null
#  balance_after   :integer          not null
#  metadata        :jsonb            not null
#  reason          :string           not null
#  source_type     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  source_id       :bigint
#  stripe_event_id :string
#  user_id         :bigint           not null
#
# Indexes
#
#  index_credit_transactions_on_source                  (source_type,source_id)
#  index_credit_transactions_on_stripe_event_id         (stripe_event_id)
#  index_credit_transactions_on_user_id                 (user_id)
#  index_credit_transactions_on_user_id_and_created_at  (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class CreditTransaction < ApplicationRecord
  REASONS = %w[
    trial_grant
    generation_debit
    generation_refund
    topup_purchase
    subscription_grant
    admin_adjustment
  ].freeze

  belongs_to :user
  belongs_to :source, polymorphic: true, optional: true

  validates :reason, inclusion: { in: REASONS }
  validates :amount, presence: true
  validates :balance_after, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
