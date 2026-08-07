# == Schema Information
#
# Table name: generation_batches
#
#  id             :bigint           not null, primary key
#  aspect_ratio   :string
#  coherence_mode :string           default("none"), not null
#  main_prompt    :text
#  status         :string           default("pending"), not null
#  style_options  :jsonb            not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_generation_batches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class GenerationBatch < ApplicationRecord
  belongs_to :user
  has_many :generation_items, dependent: :destroy

  # How much the items of a batch should look alike:
  #   none      — nothing but the shared main prompt ties them together
  #   style     — the first image guides the artistic style, each scene stays its own
  #   variation — the first image is the scene, the other items only alter it
  COHERENCE_MODES = %w[none style variation].freeze

  validates :main_prompt, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  validates :aspect_ratio, inclusion: { in: %w[1:1 16:9 9:16 4:3 3:4] }, allow_blank: true
  validates :coherence_mode, inclusion: { in: COHERENCE_MODES }

  scope :recent, -> { order(created_at: :desc) }

  def coherent?
    coherence_mode != "none"
  end

  # Both coherent modes run the whole batch through the image-to-image model, reference
  # image included, so that every item of the batch shares the same rendering.
  def image_model
    coherent? ? :nano_banana : :flux
  end

  # The first item of the batch. In coherent mode it is generated first, without any
  # reference, and its output then guides every other item of the batch.
  def reference_item
    generation_items.ordered.first
  end

  def reference_item?(item)
    item.present? && reference_item&.id == item.id
  end

  def reference_url
    reference_item&.image_url
  end

  # Every item but the reference one. Uses `where.not` rather than `offset(1)` so that
  # the relation stays composable: `offset` would apply after any extra `where`, and
  # `follower_items.where(status: 'pending')` would then skip the first pending follower.
  def follower_items
    ref = reference_item
    return generation_items.none if ref.nil?

    generation_items.ordered.where.not(id: ref.id)
  end

  def update_status!
    if generation_items.where(status: 'failed').exists? && generation_items.where(status: %w[pending processing]).none?
      update!(status: 'failed')
    elsif generation_items.all? { |item| item.status == 'completed' }
      update!(status: 'completed')
    elsif generation_items.any? { |item| item.status == 'processing' }
      update!(status: 'processing')
    end
  end
end
