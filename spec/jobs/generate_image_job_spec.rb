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
  end
end
