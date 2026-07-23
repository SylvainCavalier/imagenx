require 'open-uri'

class DownloadImageJob < ApplicationJob
  queue_as :default

  def perform(saved_image_id, image_url)
    saved_image = SavedImage.find(saved_image_id)
    return if saved_image.file.attached?

    downloaded = URI.parse(image_url).open
    content_type = downloaded.content_type || 'image/png'
    ext = case content_type
          when 'image/png' then 'png'
          when 'image/jpeg' then 'jpg'
          when 'image/webp' then 'webp'
          else 'png'
          end
    base = (saved_image.prompt.presence || "image_#{saved_image.id}").truncate(50, omission: '').parameterize.presence || "image_#{saved_image.id}"
    filename = "#{base}.#{ext}"

    saved_image.file.attach(
      io: downloaded,
      filename: filename,
      content_type: content_type
    )
  rescue => e
    Rails.logger.error "Failed to download image #{saved_image_id}: #{e.message}"
  end
end
