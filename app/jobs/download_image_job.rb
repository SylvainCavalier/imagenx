require 'open-uri'

class DownloadImageJob < ApplicationJob
  queue_as :default

  def perform(saved_image_id, image_url)
    saved_image = SavedImage.find(saved_image_id)
    return if saved_image.file.attached?

    downloaded = URI.parse(image_url).open
    filename = "image_#{saved_image.id}_#{Time.current.to_i}.webp"

    saved_image.file.attach(
      io: downloaded,
      filename: filename,
      content_type: downloaded.content_type || 'image/webp'
    )
  rescue => e
    Rails.logger.error "Failed to download image #{saved_image_id}: #{e.message}"
  end
end
