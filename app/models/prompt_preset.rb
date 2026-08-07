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
class PromptPreset < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :prompt_text, presence: true
  validates :coherence_mode, inclusion: { in: GenerationBatch::COHERENCE_MODES }

  scope :alphabetical, -> { order(name: :asc) }
end
