module Api
  class ImageFoldersController < BaseController
    def index
      folders = current_user.image_folders.recent.includes(saved_images: { file_attachment: :blob })
      render json: folders.map { |f| folder_json(f) }
    end

    def show
      folder = current_user.image_folders.includes(saved_images: { file_attachment: :blob }).find(params[:id])
      render json: folder_json(folder, include_images: true)
    end

    def create
      folder = current_user.image_folders.build(folder_params)
      if folder.save
        render json: folder_json(folder), status: :created
      else
        render json: { error: folder.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    def update
      folder = current_user.image_folders.find(params[:id])
      if folder.update(folder_params)
        render json: folder_json(folder)
      else
        render json: { error: folder.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    def destroy
      folder = current_user.image_folders.find(params[:id])
      folder.destroy!
      render json: { message: 'Folder deleted' }
    end

    private

    def folder_params
      params.permit(:name)
    end

    def folder_json(folder, include_images: false)
      data = {
        id: folder.id,
        name: folder.name,
        images_count: folder.saved_images.size,
        cover_url: folder.cover_image&.file&.attached? ? url_for(folder.cover_image.file) : nil,
        updated_at: folder.updated_at
      }
      if include_images
        data[:images] = folder.saved_images.recent.map { |img| image_json(img) }
      end
      data
    end

    def image_json(img)
      {
        id: img.id,
        prompt: img.prompt,
        url: img.file.attached? ? url_for(img.file) : img.source_url,
        created_at: img.created_at
      }
    end
  end
end
