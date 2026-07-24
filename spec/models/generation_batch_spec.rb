# == Schema Information
#
# Table name: generation_batches
#
#  id            :bigint           not null, primary key
#  aspect_ratio  :string
#  main_prompt   :text
#  status        :string           default("pending"), not null
#  style_options :jsonb            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_generation_batches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe GenerationBatch, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
