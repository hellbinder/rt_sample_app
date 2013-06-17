class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    #add indexex since well be searching for each.

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:followed_id, :follower_id], unique: true #enforeces uniqueness.
  end
end
