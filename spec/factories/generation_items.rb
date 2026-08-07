# == Schema Information
#
# Table name: generation_items
#
#  id                  :bigint           not null, primary key
#  error_message       :text
#  image_url           :string
#  position            :integer
#  prompt              :text
#  reference_image_url :string
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
FactoryBot.define do
  factory :generation_item do
    association :generation_batch
    prompt { "A red fox in a forest" }
    position { 1 }
    status { "pending" }
    image_url { nil }
    error_message { nil }
  end
end
