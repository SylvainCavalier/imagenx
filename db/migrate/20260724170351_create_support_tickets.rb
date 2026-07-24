class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subject, null: false
      t.text :message, null: false
      t.string :category, null: false
      t.string :status, default: "open", null: false
      t.text :admin_notes

      t.timestamps
    end

    add_index :support_tickets, :status
    add_index :support_tickets, :category
  end
end
