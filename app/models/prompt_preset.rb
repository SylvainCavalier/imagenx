class PromptPreset < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :prompt_text, presence: true

  scope :alphabetical, -> { order(name: :asc) }
end
