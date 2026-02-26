require 'open-uri'

module Api
  class SavedImagesController < BaseController
    def create
      folder = current_user.image_folders.find(params[:image_folder_id])

      items = params[:items] || []
      if items.empty?
        return render json: { error: 'No images to save' }, status: :unprocessable_entity
      end

      saved = []
      items.each do |item_data|
        saved_image = folder.saved_images.build(
          prompt: item_data[:prompt],
          source_url: item_data[:image_url]
        )
        saved_image.save!

        DownloadImageJob.perform_later(saved_image.id, item_data[:image_url])
        saved << saved_image
      end

      folder.touch
      render json: { saved_count: saved.size, folder_id: folder.id }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def destroy
      folder = current_user.image_folders.find(params[:image_folder_id])
      image = folder.saved_images.find(params[:id])
      image.destroy!
      render json: { message: 'Image deleted' }
    end
  end
end
