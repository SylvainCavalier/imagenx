class CreateSavedImages < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_images do |t|
      t.references :image_folder, null: false, foreign_key: true
      t.text :prompt
      t.string :source_url

      t.timestamps
    end
  end
end
