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
require 'rails_helper'

RSpec.describe GenerationItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
