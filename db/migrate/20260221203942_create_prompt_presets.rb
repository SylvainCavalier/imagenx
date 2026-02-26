class CreatePromptPresets < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_presets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :prompt_text
      t.string :aspect_ratio

      t.timestamps
    end
  end
end
