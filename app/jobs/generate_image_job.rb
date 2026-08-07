class GenerateImageJob < ApplicationJob
  queue_as :default

  # Prepended to the prompt of the items generated from the reference image. Wording
  # matters a lot here: nano-banana is an editing model, so left to itself it repaints
  # the reference rather than taking inspiration from it — 'style' has to forbid that
  # explicitly, 'variation' asks for it.
  COHERENCE_INSTRUCTIONS = {
    'style' => 'Create a completely new and different scene. Do NOT reuse the composition, framing, ' \
               'camera angle, layout, buildings or objects of the reference image, and do not edit it. ' \
               'Use it only as a style guide: match its artistic style, color palette, lighting mood, ' \
               'texture and level of detail. New scene:',
    'variation' => 'Keep the reference image as the base scene: same place, same composition, same framing, ' \
                   'same visual style, color grading and lighting. Only apply this change:'
  }.freeze

  def perform(generation_item_id)
    item = GenerationItem.find(generation_item_id)
    batch = item.generation_batch
    master = batch.reference_item?(item)

    item.update!(status: 'processing')

    reference_url = batch.coherent? && !master ? batch.reference_url : nil
    if batch.coherent? && !master && reference_url.blank?
      raise ImageGenerator::GenerationError, 'Reference image is not available'
    end

    image_url = ImageGenerator.new(model: batch.image_model).generate(
      prompt: compose_prompt(batch, item, referenced: reference_url.present?),
      aspect_ratio: batch.aspect_ratio.presence || '1:1',
      reference_urls: Array(reference_url)
    )

    item.update!(status: 'completed', image_url: image_url, reference_image_url: reference_url)
  rescue ImageGenerator::GenerationError => e
    failure = e.message
    item&.update!(status: 'failed', error_message: failure)
    refund_credits!(item)
  rescue => e
    failure = "Unexpected error: #{e.message}"
    item&.update!(status: 'failed', error_message: failure)
    refund_credits!(item)
  ensure
    # Settling from `ensure` is deliberate: done inside the begin block, an exception
    # raised while enqueueing the followers would be caught by the rescues above and
    # would mark a master that actually generated (and was billed) as failed.
    settle_coherent_batch(batch, failure) if master && batch&.coherent?
    batch&.update_status!
  end

  private

  def compose_prompt(batch, item, referenced: false)
    return full_prompt(batch, item) unless referenced

    instruction = COHERENCE_INSTRUCTIONS[batch.coherence_mode]
    return full_prompt(batch, item) if instruction.blank?

    # In variation mode the reference image already carries the scene and the style, so the
    # prompt is reduced to what the user wants changed: repeating the main prompt there
    # reads as "generate that whole scene again" and fights the edit.
    body = batch.coherence_mode == 'variation' ? item.prompt.to_s.strip : full_prompt(batch, item)

    "#{instruction} #{body}"
  end

  def full_prompt(batch, item)
    parts = (batch.style_options || {}).values
    parts += [batch.main_prompt, item.prompt]
    parts.reject(&:blank?).join(', ')
  end

  # Once the reference item of a coherent batch is done, the rest of the batch either
  # starts (success) or is cancelled and refunded (failure) — those items were debited
  # upfront when the batch was created and would otherwise stay pending forever.
  def settle_coherent_batch(batch, failure)
    if failure.nil?
      BatchDispatcher.dispatch_followers(batch)
    else
      fail_followers!(batch, failure)
    end
  rescue => e
    Rails.logger.error "[GenerateImageJob] Settling coherent batch #{batch.id} failed: #{e.message}"
  end

  def fail_followers!(batch, failure)
    message = "Reference image failed: #{failure}"

    batch.follower_items.where(status: %w[pending processing]).to_a.each do |follower|
      # Conditional UPDATE, same idea as User.debit_credits: only the call that actually
      # flipped the status refunds, so a replay cannot refund the same item twice.
      claimed = GenerationItem.where(id: follower.id, status: %w[pending processing])
                              .update_all(status: 'failed', error_message: message, updated_at: Time.current)
      refund_credits!(follower) if claimed == 1
    end
  end

  def refund_credits!(item)
    return unless item

    item.generation_batch.user.add_credits!(
      User::GENERATION_COST_PER_IMAGE,
      reason: 'generation_refund',
      source: item
    )
  end
end
