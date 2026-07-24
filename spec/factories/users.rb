# == Schema Information
#
# Table name: users
#
#  id                                :bigint           not null, primary key
#  api_token                         :string
#  confirmation_sent_at              :datetime
#  confirmation_token                :string
#  confirmed_at                      :datetime
#  credits_balance                   :integer          default(0), not null
#  email                             :string           default(""), not null
#  encrypted_password                :string           default(""), not null
#  name                              :string
#  remember_created_at               :datetime
#  reset_password_sent_at            :datetime
#  reset_password_token              :string
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
#  index_users_on_api_token               (api_token) UNIQUE
#  index_users_on_confirmation_token      (confirmation_token) UNIQUE
#  index_users_on_email                   (email) UNIQUE
#  index_users_on_reset_password_token    (reset_password_token) UNIQUE
#  index_users_on_stripe_customer_id      (stripe_customer_id) UNIQUE
#  index_users_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :with_credits do
      transient do
        starting_credits { 100 }
      end

      after(:create) do |user, evaluator|
        user.update_column(:credits_balance, evaluator.starting_credits)
      end
    end
  end
end
