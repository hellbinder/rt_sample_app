class AddPasswordResetHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_hash, :string
  end
end
