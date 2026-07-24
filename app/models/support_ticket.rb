# == Schema Information
#
# Table name: support_tickets
#
#  id          :bigint           not null, primary key
#  admin_notes :text
#  category    :string           not null
#  message     :text             not null
#  status      :string           default("open"), not null
#  subject     :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_support_tickets_on_category  (category)
#  index_support_tickets_on_status    (status)
#  index_support_tickets_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class SupportTicket < ApplicationRecord
  CATEGORIES = %w[technical billing idea].freeze
  STATUSES = %w[open in_progress resolved closed].freeze

  belongs_to :user

  validates :subject, presence: true, length: { maximum: 200 }
  validates :message, presence: true, length: { maximum: 5000 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
end
