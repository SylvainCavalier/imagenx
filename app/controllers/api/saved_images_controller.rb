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

    def update
      folder = current_user.image_folders.find(params[:image_folder_id])
      image = folder.saved_images.find(params[:id])
      image.update!(prompt: params[:prompt])
      render json: { id: image.id, prompt: image.prompt }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def download
      folder = current_user.image_folders.find(params[:image_folder_id])
      image = folder.saved_images.find(params[:id])

      unless image.file.attached?
        return render json: { error: 'Image not yet available' }, status: :not_found
      end

      filename = (image.prompt.presence || 'image').truncate(50, omission: '').parameterize + '.png'

      if image.file.content_type == 'image/png'
        redirect_to rails_blob_path(image.file, disposition: :attachment, filename: filename), allow_other_host: true
      else
        variant = image.file.variant(format: :png).processed
        redirect_to rails_representation_path(variant, disposition: :attachment, filename: filename), allow_other_host: true
      end
    end

    def destroy
      folder = current_user.image_folders.find(params[:image_folder_id])
      image = folder.saved_images.find(params[:id])
      image.destroy!
      render json: { message: 'Image deleted' }
    end
  end
end
