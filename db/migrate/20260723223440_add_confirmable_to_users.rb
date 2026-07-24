class AddConfirmableToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :confirmation_token, :string
    add_index :users, :confirmation_token, unique: true
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    # Existing users predate :confirmable — grandfather them in so they aren't locked out.
    execute "UPDATE users SET confirmed_at = NOW() WHERE confirmed_at IS NULL"
  end

  def down
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
  end
end
