module Api
  class GenerationBatchesController < BaseController
    # Disable automatic parameter wrapping for this controller
    wrap_parameters false

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

      ActiveRecord::Base.transaction do
        batch.save!
        items_data.each_with_index do |item, index|
          batch.generation_items.create!(
            prompt: item[:prompt],
            position: index,
            status: 'pending'
          )
        end
      end

      batch.update!(status: 'processing')
      batch.generation_items.each_with_index do |item, idx|
        GenerateImageJob.set(wait: idx * 12.seconds).perform_later(item.id)
      end

      render json: batch_json(batch.reload), status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def batch_params
      params.permit(:main_prompt, :aspect_ratio)
    end

    def batch_json(batch)
      {
        id: batch.id,
        main_prompt: batch.main_prompt,
        aspect_ratio: batch.aspect_ratio,
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
        error_message: item.error_message
      }
    end
  end
end
