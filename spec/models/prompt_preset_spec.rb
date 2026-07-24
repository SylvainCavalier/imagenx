# == Schema Information
#
# Table name: prompt_presets
#
#  id            :bigint           not null, primary key
#  aspect_ratio  :string
#  name          :string
#  prompt_text   :text
#  style_options :jsonb            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_prompt_presets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe PromptPreset, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
