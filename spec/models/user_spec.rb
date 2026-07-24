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
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#grant_trial_credits' do
    it 'grants TRIAL_CREDITS on creation and records it in the ledger' do
      user = create(:user)

      expect(user.credits_balance).to eq(User::TRIAL_CREDITS)
      expect(user.credit_transactions.count).to eq(1)

      transaction = user.credit_transactions.first
      expect(transaction.amount).to eq(User::TRIAL_CREDITS)
      expect(transaction.balance_after).to eq(User::TRIAL_CREDITS)
      expect(transaction.reason).to eq('trial_grant')
    end
  end

  describe '#add_credits!' do
    it 'increments the balance and records a ledger row' do
      user = create(:user, :with_credits, starting_credits: 10)

      user.add_credits!(50, reason: 'topup_purchase')

      expect(user.reload.credits_balance).to eq(60)
      transaction = user.credit_transactions.order(:created_at).last
      expect(transaction.amount).to eq(50)
      expect(transaction.balance_after).to eq(60)
      expect(transaction.reason).to eq('topup_purchase')
    end

    it 'raises for a non-positive amount' do
      user = create(:user)
      expect { user.add_credits!(0, reason: 'admin_adjustment') }.to raise_error(ArgumentError)
    end
  end

  describe '.debit_credits' do
    it 'debits the balance when sufficient' do
      user = create(:user, :with_credits, starting_credits: 100)

      expect(User.debit_credits(user.id, 40)).to eq(true)
      expect(user.reload.credits_balance).to eq(60)
    end

    it 'refuses to debit below zero' do
      user = create(:user, :with_credits, starting_credits: 10)

      expect(User.debit_credits(user.id, 40)).to eq(false)
      expect(user.reload.credits_balance).to eq(10)
    end

    # Exercises the exact race the conditional UPDATE is meant to close: two
    # concurrent debits against a balance that can only cover one of them must
    # not both succeed. Transactional fixtures are disabled for this example so
    # the spawned threads (separate DB connections) can see the already-committed
    # user row; the user is cleaned up manually afterwards.
    context 'under concurrent access' do
      self.use_transactional_tests = false

      it 'allows only one of two simultaneous debits to succeed when funds cover just one' do
        user = create(:user, :with_credits, starting_credits: 40)

        results = []
        threads = 2.times.map do
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              results << User.debit_credits(user.id, 40)
            end
          end
        end
        threads.each(&:join)

        expect(results.count(true)).to eq(1)
        expect(user.reload.credits_balance).to eq(0)
      ensure
        user&.destroy
      end
    end
  end
end
