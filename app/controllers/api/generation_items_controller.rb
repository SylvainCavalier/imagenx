require 'open-uri'

module Api
  class GenerationItemsController < BaseController
    def download
      batch = current_user.generation_batches.find(params[:generation_batch_id])
      item = batch.generation_items.find(params[:id])

      unless item.image_url.present?
        return render json: { error: 'Image not yet available' }, status: :not_found
      end

      filename = (item.prompt.presence || 'image').truncate(50, omission: '').parameterize + '.png'

      downloaded = URI.parse(item.image_url).open
      png_data = ImageProcessing::Vips.source(downloaded).convert('png').call

      send_file png_data.path, filename: filename, type: 'image/png', disposition: :attachment
    end
  end
end
