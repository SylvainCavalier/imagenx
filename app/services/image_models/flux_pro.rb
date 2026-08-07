module ImageModels
  # Default text-to-image model. Ignores reference images: it has no image-to-image input.
  class FluxPro
    ENDPOINT = "https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro/predictions".freeze
    ASPECT_RATIOS = %w[1:1 16:9 9:16 4:3 3:4].freeze

    def endpoint
      ENDPOINT
    end

    # Accepts and ignores `reference_urls:` so that callers can stay model-agnostic.
    def input(prompt:, aspect_ratio:, **)
      { prompt: prompt, aspect_ratio: ratio(aspect_ratio), output_format: "png" }
    end

    private

    def ratio(value)
      ASPECT_RATIOS.include?(value) ? value : "1:1"
    end
  end
end
