class GenerateImageJob < ApplicationJob
  queue_as :default

  def perform(generation_item_id)
    item = GenerationItem.find(generation_item_id)
    batch = item.generation_batch

    item.update!(status: 'processing')

    style_parts = (batch.style_options || {}).values.reject(&:blank?)
    full_prompt = [*style_parts, batch.main_prompt, item.prompt].reject(&:blank?).join(', ')
    generator = ImageGenerator.new
    image_url = generator.generate(prompt: full_prompt, aspect_ratio: batch.aspect_ratio.presence || '1:1')

    item.update!(status: 'completed', image_url: image_url)
  rescue ImageGenerator::GenerationError => e
    item&.update!(status: 'failed', error_message: e.message)
  rescue => e
    item&.update!(status: 'failed', error_message: "Unexpected error: #{e.message}")
  ensure
    batch&.update_status!
  end
end
