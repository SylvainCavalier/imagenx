class CreateGenerationBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :generation_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.text :main_prompt
      t.string :aspect_ratio
      t.string :status, default: 'pending', null: false

      t.timestamps
    end
  end
end
