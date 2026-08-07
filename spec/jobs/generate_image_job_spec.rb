require 'rails_helper'

RSpec.describe GenerateImageJob, type: :job do
  let(:user) { create(:user, :with_credits, starting_credits: 100) }
  let(:batch) { create(:generation_batch, user: user) }
  let(:item) { create(:generation_item, generation_batch: batch) }

  describe '#perform' do
    context 'when generation succeeds' do
      before do
        allow_any_instance_of(ImageGenerator).to receive(:generate).and_return('https://example.com/fake.png')
      end

      it 'completes the item and does not refund credits' do
        expect {
          described_class.new.perform(item.id)
        }.not_to change { user.reload.credits_balance }

        expect(item.reload.status).to eq('completed')
        expect(CreditTransaction.where(reason: 'generation_refund')).to be_empty
      end
    end

    context 'when generation fails' do
      before do
        allow_any_instance_of(ImageGenerator).to receive(:generate)
          .and_raise(ImageGenerator::GenerationError, 'boom')
      end

      it 'marks the item failed and refunds the fixed cost per image' do
        expect {
          described_class.new.perform(item.id)
        }.to change { user.reload.credits_balance }.by(User::GENERATION_COST_PER_IMAGE)

        expect(item.reload.status).to eq('failed')

        refund = CreditTransaction.find_by(reason: 'generation_refund')
        expect(refund).to be_present
        expect(refund.amount).to eq(User::GENERATION_COST_PER_IMAGE)
        expect(refund.source).to eq(item)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow_any_instance_of(ImageGenerator).to receive(:generate).and_raise(StandardError, 'kaboom')
      end

      it 'marks the item failed and still refunds' do
        expect {
          described_class.new.perform(item.id)
        }.to change { user.reload.credits_balance }.by(User::GENERATION_COST_PER_IMAGE)

        expect(item.reload.status).to eq('failed')
        expect(item.error_message).to include('kaboom')
      end
    end

    it 'uses the default model for a regular batch' do
      expect(ImageGenerator).to receive(:new).with(model: :flux)
        .and_return(instance_double(ImageGenerator, generate: 'https://example.com/fake.png'))

      described_class.new.perform(item.id)
    end
  end

  describe '#perform on a coherent batch' do
    # The real GoodJob adapter runs jobs inline in test: without the test adapter the
    # first follower (enqueued with wait: 0) would actually run inside these examples.
    around do |example|
      previous = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      example.run
      ActiveJob::Base.queue_adapter = previous
    end

    # status mirrors what the controller sets right before dispatching
    let(:batch) { create(:generation_batch, :style_coherence, user: user, status: 'processing') }
    let!(:master) { create(:generation_item, generation_batch: batch, position: 0, prompt: 'A red fox') }
    let!(:follower_one) { create(:generation_item, generation_batch: batch, position: 1, prompt: 'A wolf') }
    let!(:follower_two) { create(:generation_item, generation_batch: batch, position: 2, prompt: 'A bear') }

    context 'when the reference item succeeds' do
      before do
        allow_any_instance_of(ImageGenerator).to receive(:generate).and_return('https://example.com/master.png')
      end

      it 'enqueues the followers without refunding anything' do
        expect {
          described_class.new.perform(master.id)
        }.not_to change { user.reload.credits_balance }

        expect(master.reload.status).to eq('completed')
        expect(GenerateImageJob).to have_been_enqueued.with(follower_one.id)
        expect(GenerateImageJob).to have_been_enqueued.with(follower_two.id)
        expect(batch.reload.status).to eq('processing')
      end

      it 'generates the reference itself with no reference image' do
        generator = instance_double(ImageGenerator, generate: 'https://example.com/master.png')
        expect(ImageGenerator).to receive(:new).with(model: :nano_banana).and_return(generator)
        expect(generator).to receive(:generate).with(hash_including(reference_urls: []))

        described_class.new.perform(master.id)
        expect(master.reload.reference_image_url).to be_nil
      end
    end

    context 'when a follower runs after the reference completed' do
      before do
        master.update!(status: 'completed', image_url: 'https://example.com/master.png')
      end

      it 'passes the reference image and the style instruction to the model' do
        generator = instance_double(ImageGenerator, generate: 'https://example.com/follower.png')
        allow(ImageGenerator).to receive(:new).with(model: :nano_banana).and_return(generator)
        expect(generator).to receive(:generate) do |args|
          expect(args[:reference_urls]).to eq(['https://example.com/master.png'])
          expect(args[:prompt]).to start_with(described_class::COHERENCE_INSTRUCTIONS['style'])
          expect(args[:prompt]).to include('A wolf')
          'https://example.com/follower.png'
        end

        described_class.new.perform(follower_one.id)

        expect(follower_one.reload.reference_image_url).to eq('https://example.com/master.png')
        expect(follower_one.status).to eq('completed')
      end

      context 'in variation mode' do
        let(:batch) { create(:generation_batch, :variation_coherence, user: user, status: 'processing') }

        let(:batch) do
          create(:generation_batch, :variation_coherence, user: user, status: 'processing',
                                                          main_prompt: 'A medieval village')
        end

        it 'keeps the reference scene and only sends what changes' do
          generator = instance_double(ImageGenerator, generate: 'https://example.com/follower.png')
          allow(ImageGenerator).to receive(:new).with(model: :nano_banana).and_return(generator)
          expect(generator).to receive(:generate) do |args|
            expect(args[:prompt])
              .to eq("#{described_class::COHERENCE_INSTRUCTIONS['variation']} A wolf")
            'https://example.com/follower.png'
          end

          described_class.new.perform(follower_one.id)
        end

        it 'still sends the full prompt for the reference item itself' do
          generator = instance_double(ImageGenerator, generate: 'https://example.com/master.png')
          allow(ImageGenerator).to receive(:new).with(model: :nano_banana).and_return(generator)
          expect(generator).to receive(:generate) do |args|
            expect(args[:prompt]).to eq('A medieval village, A red fox')
            'https://example.com/master.png'
          end

          described_class.new.perform(master.id)
        end
      end
    end

    context 'when the reference item has no image url' do
      before { master.update!(status: 'completed', image_url: nil) }

      it 'fails the follower and refunds it' do
        expect {
          described_class.new.perform(follower_one.id)
        }.to change { user.reload.credits_balance }.by(User::GENERATION_COST_PER_IMAGE)

        expect(follower_one.reload.status).to eq('failed')
        expect(follower_one.error_message).to include('Reference image is not available')
      end
    end

    context 'when the reference item fails' do
      before do
        allow_any_instance_of(ImageGenerator).to receive(:generate)
          .and_raise(ImageGenerator::GenerationError, 'boom')
      end

      it 'fails the whole batch and refunds every item' do
        expect {
          described_class.new.perform(master.id)
        }.to change { user.reload.credits_balance }.by(3 * User::GENERATION_COST_PER_IMAGE)

        expect([master, follower_one, follower_two].map { |i| i.reload.status }).to all(eq('failed'))
        expect(follower_one.error_message).to eq('Reference image failed: boom')
        expect(CreditTransaction.where(reason: 'generation_refund').count).to eq(3)
        expect(GenerateImageJob).not_to have_been_enqueued
        expect(batch.reload.status).to eq('failed')
      end

      it 'does not refund the followers twice when replayed' do
        described_class.new.perform(master.id)

        expect {
          described_class.new.perform(master.id)
        }.to change { user.reload.credits_balance }.by(User::GENERATION_COST_PER_IMAGE)

        expect(CreditTransaction.where(reason: 'generation_refund', source: follower_one).count).to eq(1)
        expect(CreditTransaction.where(reason: 'generation_refund', source: follower_two).count).to eq(1)
      end
    end
  end
end
