require 'rails_helper'

RSpec.describe 'Api::GenerationBatches', type: :request do
  let(:user) { create(:user, :with_credits, starting_credits: 100) }

  before do
    sign_in user
    # GoodJob runs jobs inline in test, so GenerateImageJob actually executes within
    # the request — stub the external call, these specs only care about the debit.
    allow_any_instance_of(ImageGenerator).to receive(:generate).and_return('https://example.com/fake.png')
  end

  describe 'POST /api/generation_batches' do
    let(:params) do
      {
        main_prompt: 'A cinematic photograph',
        aspect_ratio: '1:1',
        items: [{ prompt: 'A red fox' }, { prompt: 'A mountain peak' }]
      }
    end

    it 'debits the fixed cost per image and records a ledger entry' do
      expect {
        post '/api/generation_batches', params: params
      }.to change { user.reload.credits_balance }.by(-2 * User::GENERATION_COST_PER_IMAGE)
        .and change(GenerationBatch, :count).by(1)
        .and change(GenerationItem, :count).by(2)
        .and change(CreditTransaction, :count).by(1)

      expect(response).to have_http_status(:created)

      transaction = CreditTransaction.order(:created_at).last
      expect(transaction.reason).to eq('generation_debit')
      expect(transaction.amount).to eq(-2 * User::GENERATION_COST_PER_IMAGE)
      expect(transaction.balance_after).to eq(user.reload.credits_balance)
    end

    context 'in coherent mode' do
      it 'persists the mode and debits exactly the same amount' do
        expect {
          post '/api/generation_batches', params: params.merge(coherence_mode: 'style')
        }.to change { user.reload.credits_balance }.by(-2 * User::GENERATION_COST_PER_IMAGE)

        expect(GenerationBatch.last.coherence_mode).to eq('style')
        expect(JSON.parse(response.body)['coherence_mode']).to eq('style')
      end

      it 'accepts the variation mode too' do
        post '/api/generation_batches', params: params.merge(coherence_mode: 'variation')

        expect(GenerationBatch.last.coherence_mode).to eq('variation')
      end

      it 'rejects an unknown mode without debiting' do
        expect {
          post '/api/generation_batches', params: params.merge(coherence_mode: 'maximum')
        }.not_to change { user.reload.credits_balance }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(GenerationBatch.count).to eq(0)
      end

      context 'without inline execution' do
        include ActiveJob::TestHelper

        around do |example|
          previous = ActiveJob::Base.queue_adapter
          ActiveJob::Base.queue_adapter = :test
          example.run
          ActiveJob::Base.queue_adapter = previous
        end

        it 'only dispatches the reference item, the followers wait for it' do
          post '/api/generation_batches', params: params.merge(coherence_mode: 'style')

          items = GenerationBatch.last.generation_items.ordered
          expect(GenerateImageJob).to have_been_enqueued.once.with(items.first.id)
          expect(items.last.status).to eq('pending')
        end

        it 'dispatches every item at once for a regular batch' do
          post '/api/generation_batches', params: params

          expect(GenerateImageJob).to have_been_enqueued.exactly(2).times
        end
      end

      it 'turns the mode off for a single-image batch' do
        post '/api/generation_batches',
             params: params.merge(coherence_mode: 'style', items: [{ prompt: 'A red fox' }])

        expect(GenerationBatch.last.coherence_mode).to eq('none')
      end
    end

    it 'defaults to a non-coherent batch' do
      post '/api/generation_batches', params: params

      expect(GenerationBatch.last.coherence_mode).to eq('none')
      expect(JSON.parse(response.body)['items'].first).to have_key('reference_image_url')
    end

    context 'when the balance is insufficient' do
      let(:user) { create(:user, :with_credits, starting_credits: 5) }

      it 'creates nothing and leaves the balance untouched' do
        balance_before = user.credits_balance
        ledger_count_before = CreditTransaction.count

        post '/api/generation_batches', params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Not enough credits')
        expect(user.reload.credits_balance).to eq(balance_before)
        expect(GenerationBatch.count).to eq(0)
        expect(GenerationItem.count).to eq(0)
        expect(CreditTransaction.count).to eq(ledger_count_before)
      end
    end
  end
end
