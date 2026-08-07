# == Schema Information
#
# Table name: prompt_presets
#
#  id             :bigint           not null, primary key
#  aspect_ratio   :string
#  coherence_mode :string           default("none"), not null
#  name           :string
#  prompt_text    :text
#  style_options  :jsonb            not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_prompt_presets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :prompt_preset do
    user { nil }
    name { "MyString" }
    prompt_text { "MyText" }
    aspect_ratio { "MyString" }
  end
end
