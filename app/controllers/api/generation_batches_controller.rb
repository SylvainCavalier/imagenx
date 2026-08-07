module Api
  class GenerationBatchesController < BaseController
    # Disable automatic parameter wrapping for this controller
    wrap_parameters false

    class InsufficientCredits < StandardError; end

    def index
      batches = current_user.generation_batches.recent.includes(:generation_items)
      render json: batches.map { |b| batch_json(b) }
    end

    def show
      batch = current_user.generation_batches.includes(:generation_items).find(params[:id])
      render json: batch_json(batch)
    end

    def create
      batch = current_user.generation_batches.build(batch_params)
      batch.status = 'pending'

      items_data = params[:items] || []
      if items_data.empty?
        return render json: { error: 'At least one image prompt is required' }, status: :unprocessable_entity
      end

      # A single image has nothing to be consistent with, and a coherence mode would
      # silently switch it to another provider — persist what is actually done.
      batch.coherence_mode = 'none' if items_data.size < 2

      total_cost = items_data.size * User::GENERATION_COST_PER_IMAGE

      ActiveRecord::Base.transaction do
        unless User.debit_credits(current_user.id, total_cost)
          raise InsufficientCredits
        end

        batch.save!
        items_data.each_with_index do |item, index|
          batch.generation_items.create!(
            prompt: item[:prompt],
            position: index,
            status: 'pending'
          )
        end

        current_user.credit_transactions.create!(
          amount: -total_cost,
          balance_after: current_user.reload.credits_balance,
          reason: 'generation_debit',
          source: batch
        )
      end

      batch.update!(status: 'processing')
      # reload so that `reference_item` reads from the database rather than from the
      # association cache the `create!` calls above have populated.
      BatchDispatcher.dispatch_initial(batch.reload)

      render json: batch_json(batch.reload), status: :created
    rescue InsufficientCredits
      render json: { error: 'Not enough credits' }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def batch_params
      params.permit(:main_prompt, :aspect_ratio, :coherence_mode, style_options: {})
    end

    def batch_json(batch)
      {
        id: batch.id,
        main_prompt: batch.main_prompt,
        aspect_ratio: batch.aspect_ratio,
        style_options: batch.style_options,
        coherence_mode: batch.coherence_mode,
        status: batch.status,
        created_at: batch.created_at,
        items: batch.generation_items.ordered.map { |item| item_json(item) }
      }
    end

    def item_json(item)
      {
        id: item.id,
        prompt: item.prompt,
        position: item.position,
        status: item.status,
        image_url: item.image_url,
        reference_image_url: item.reference_image_url,
        error_message: item.error_message
      }
    end
  end
end
