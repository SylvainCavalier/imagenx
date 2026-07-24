class User < ApplicationRecord
  TRIAL_CREDITS = 20

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  has_secure_token :api_token

  has_many :generation_batches, dependent: :destroy
  has_many :image_folders, dependent: :destroy
  has_many :prompt_presets, dependent: :destroy

  after_create :grant_trial_credits

  private

  def grant_trial_credits
    update_column(:credits_balance, TRIAL_CREDITS)
  end
end
