# == Schema Information
#
# Table name: image_folders
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_image_folders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ImageFolder < ApplicationRecord
  belongs_to :user
  has_many :saved_images, dependent: :destroy

  validates :name, presence: true

  scope :recent, -> { order(updated_at: :desc) }

  def cover_image
    saved_images.order(created_at: :desc).first
  end
end
