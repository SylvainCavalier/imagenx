# == Schema Information
#
# Table name: stripe_events
#
#  id              :bigint           not null, primary key
#  event_type      :string           not null
#  processed_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  stripe_event_id :string           not null
#
# Indexes
#
#  index_stripe_events_on_stripe_event_id  (stripe_event_id) UNIQUE
#
class StripeEvent < ApplicationRecord
  validates :stripe_event_id, presence: true, uniqueness: true
  validates :event_type, presence: true
end
