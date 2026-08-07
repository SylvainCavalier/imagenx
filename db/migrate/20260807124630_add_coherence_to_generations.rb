class AddCoherenceToGenerations < ActiveRecord::Migration[8.0]
  def change
    add_column :generation_batches, :coherence_mode, :string, null: false, default: "none"
    add_column :prompt_presets, :coherence_mode, :string, null: false, default: "none"
    add_column :generation_items, :reference_image_url, :string
  end
end
