class AddUniqueConstraintToTables < ActiveRecord::Migration
  def change
    add_index :users, :api_access_token, :unique => true
    add_index :elsewheres, [:uid, :provider], :unique => true
    add_index :android_apps, :uid, :unique => true
    add_index :movies, :imdb_id, :unique => true
    add_index :recommendations, [:item_id, :recommendee_id, :recommender_id, :item_type], :unique => true, :name => 'index_for_unique_recommendation'
    add_index :requests, [:item_type, :requestee_id, :requester_id], :where => "status IN ('pending','sent')", :unique => true
    # add_index :user_followers, [:following_id, :follower_id], :unique => true
    add_index :user_items, [:user_id, :item_id, :item_type], :unique => true
  end
end
