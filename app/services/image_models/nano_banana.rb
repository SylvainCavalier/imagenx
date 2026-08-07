module ImageModels
  # Image-to-image model used by coherent batches: `image_input` takes reference images
  # the generation should stay visually consistent with. Exposes no seed, so the
  # reference image is the only consistency lever.
  class NanoBanana
    ENDPOINT = "https://api.replicate.com/v1/models/google/nano-banana/predictions".freeze
    ASPECT_RATIOS = %w[1:1 2:3 3:2 3:4 4:3 4:5 5:4 9:16 16:9 21:9].freeze

    def endpoint
      ENDPOINT
    end

    # `output_format` defaults to jpg on this model: png is forced so that downloads and
    # Active Storage attachments stay on the same path as flux-generated images.
    def input(prompt:, aspect_ratio:, reference_urls: [])
      input = { prompt: prompt, aspect_ratio: ratio(aspect_ratio), output_format: "png" }
      input[:image_input] = reference_urls if reference_urls.any?
      input
    end

    private

    def ratio(value)
      ASPECT_RATIOS.include?(value) ? value : "1:1"
    end
  end
end
