class AddUserRecommendations < ActiveRecord::Migration
  def change
  	create_table :recommendations do |t|
        t.integer :recommender_id
        t.integer :recommendee_id
        t.integer :item_id
        t.string :item_type
        t.string :status
        t.timestamps
    end
  end
end
