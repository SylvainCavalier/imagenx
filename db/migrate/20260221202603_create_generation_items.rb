class CreateGenerationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :generation_items do |t|
      t.references :generation_batch, null: false, foreign_key: true
      t.text :prompt
      t.integer :position
      t.string :status, default: 'pending', null: false
      t.string :image_url
      t.text :error_message

      t.timestamps
    end
  end
end
