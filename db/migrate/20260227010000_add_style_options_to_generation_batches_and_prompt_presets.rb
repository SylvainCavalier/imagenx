class AddStyleOptionsToGenerationBatchesAndPromptPresets < ActiveRecord::Migration[8.0]
  def change
    add_column :generation_batches, :style_options, :jsonb, default: {}, null: false
    add_column :prompt_presets, :style_options, :jsonb, default: {}, null: false
  end
end
