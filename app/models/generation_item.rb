# == Schema Information
#
# Table name: generation_items
#
#  id                  :bigint           not null, primary key
#  error_message       :text
#  image_url           :string
#  position            :integer
#  prompt              :text
#  status              :string           default("pending"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  generation_batch_id :bigint           not null
#
# Indexes
#
#  index_generation_items_on_generation_batch_id  (generation_batch_id)
#
# Foreign Keys
#
#  fk_rails_...  (generation_batch_id => generation_batches.id)
#
class GenerationItem < ApplicationRecord
  belongs_to :generation_batch

  validates :prompt, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }

  scope :ordered, -> { order(position: :asc) }
end
