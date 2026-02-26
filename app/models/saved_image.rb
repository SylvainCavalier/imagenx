class SavedImage < ApplicationRecord
  belongs_to :image_folder

  has_one_attached :file

  validates :prompt, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
