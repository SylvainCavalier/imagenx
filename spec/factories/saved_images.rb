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
FactoryBot.define do
  factory :saved_image do
    image_folder { nil }
    prompt { "MyText" }
    source_url { "MyString" }
  end
end
