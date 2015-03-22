class AddUserFollowersTable < ActiveRecord::Migration
  def change
    create_table :user_followers do |t|
      t.integer :follower_id
      t.integer :following_id
      t.string :derived_from
      t.timestamps
    end
    add_index :user_followers, [:follower_id, :following_id], unique: true
  end
end
