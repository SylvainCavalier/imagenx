class CreateCreditTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.integer :balance_after, null: false
      t.string :reason, null: false
      t.references :source, polymorphic: true, null: true
      t.string :stripe_event_id
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :credit_transactions, [:user_id, :created_at]
    add_index :credit_transactions, :stripe_event_id
  end
end
