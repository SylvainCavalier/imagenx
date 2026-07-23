module Api
  class PromptPresetsController < BaseController
    def index
      presets = current_user.prompt_presets.alphabetical
      render json: presets.map { |p| preset_json(p) }
    end

    def create
      preset = current_user.prompt_presets.build(preset_params)
      if preset.save
        render json: preset_json(preset), status: :created
      else
        render json: { error: preset.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    def update
      preset = current_user.prompt_presets.find(params[:id])
      if preset.update(preset_params)
        render json: preset_json(preset)
      else
        render json: { error: preset.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end

    def destroy
      preset = current_user.prompt_presets.find(params[:id])
      preset.destroy!
      render json: { message: 'Preset deleted' }
    end

    private

    def preset_params
      params.permit(:name, :prompt_text, :aspect_ratio, style_options: {})
    end

    def preset_json(preset)
      {
        id: preset.id,
        name: preset.name,
        prompt_text: preset.prompt_text,
        aspect_ratio: preset.aspect_ratio,
        style_options: preset.style_options
      }
    end
  end
end
