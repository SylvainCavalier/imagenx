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
require 'rails_helper'

RSpec.describe GenerationBatch, type: :model do
  let(:batch) { create(:generation_batch) }
  let!(:first) { create(:generation_item, generation_batch: batch, position: 0) }
  let!(:second) { create(:generation_item, generation_batch: batch, position: 1) }
  let!(:third) { create(:generation_item, generation_batch: batch, position: 2) }

  describe '#image_model' do
    it 'switches to the image-to-image model for both coherence modes' do
      expect(batch.image_model).to eq(:flux)
      expect(create(:generation_batch, :style_coherence).image_model).to eq(:nano_banana)
      expect(create(:generation_batch, :variation_coherence).image_model).to eq(:nano_banana)
    end

    it 'defaults to no coherence' do
      expect(batch.coherence_mode).to eq('none')
      expect(batch).not_to be_coherent
    end

    it 'rejects an unknown mode' do
      expect(build(:generation_batch, coherence_mode: 'maximum')).not_to be_valid
    end
  end

  describe '#reference_item' do
    it 'is the first item of the batch' do
      expect(batch.reference_item).to eq(first)
      expect(batch.reference_item?(first)).to be(true)
      expect(batch.reference_item?(second)).to be(false)
    end

    it 'exposes its image url' do
      first.update!(image_url: 'https://example.com/master.png')
      expect(batch.reload.reference_url).to eq('https://example.com/master.png')
    end
  end

  describe '#follower_items' do
    it 'excludes the reference item' do
      expect(batch.follower_items).to contain_exactly(second, third)
    end

    it 'stays composable with a further scope' do
      # offset(1) would apply after the where and drop the first pending follower
      second.update!(status: 'processing')

      expect(batch.follower_items.where(status: 'pending')).to contain_exactly(third)
    end

    it 'is empty when the batch has no item' do
      expect(create(:generation_batch).follower_items).to be_empty
    end
  end
end
