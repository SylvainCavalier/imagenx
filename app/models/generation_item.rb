class GenerationItem < ApplicationRecord
  belongs_to :generation_batch

  validates :prompt, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }

  scope :ordered, -> { order(position: :asc) }
end
