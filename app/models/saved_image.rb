# == Schema Information
#
# Table name: saved_images
#
#  id              :bigint           not null, primary key
#  prompt          :text
#  source_url      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  image_folder_id :bigint           not null
#
# Indexes
#
#  index_saved_images_on_image_folder_id  (image_folder_id)
#
# Foreign Keys
#
#  fk_rails_...  (image_folder_id => image_folders.id)
#
class SavedImage < ApplicationRecord
  belongs_to :image_folder

  has_one_attached :file

  validates :prompt, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
