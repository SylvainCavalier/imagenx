class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :generation_batches, dependent: :destroy
  has_many :image_folders, dependent: :destroy
  has_many :prompt_presets, dependent: :destroy
end
