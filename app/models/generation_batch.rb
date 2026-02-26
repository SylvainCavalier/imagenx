class GenerationBatch < ApplicationRecord
  belongs_to :user
  has_many :generation_items, dependent: :destroy

  validates :main_prompt, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  validates :aspect_ratio, inclusion: { in: %w[1:1 16:9 9:16 4:3 3:4] }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }

  def update_status!
    if generation_items.where(status: 'failed').exists? && generation_items.where(status: %w[pending processing]).none?
      update!(status: 'failed')
    elsif generation_items.all? { |item| item.status == 'completed' }
      update!(status: 'completed')
    elsif generation_items.any? { |item| item.status == 'processing' }
      update!(status: 'processing')
    end
  end
end
