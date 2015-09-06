class AddLikeToUserItems < ActiveRecord::Migration
  def change
    add_column :user_items, :like, :boolean
  end
end
