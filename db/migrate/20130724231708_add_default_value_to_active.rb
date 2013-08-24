class AddDefaultValueToActive < ActiveRecord::Migration
  def up
    change_column :users, :active, :boolean, default: false
  end

  def down
    change_column :users, :active, :boolean, default: nil 
  end
end