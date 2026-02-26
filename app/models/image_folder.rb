class ImageFolder < ApplicationRecord
  belongs_to :user
  has_many :saved_images, dependent: :destroy

  validates :name, presence: true

  scope :recent, -> { order(updated_at: :desc) }

  def cover_image
    saved_images.order(created_at: :desc).first
  end
end
