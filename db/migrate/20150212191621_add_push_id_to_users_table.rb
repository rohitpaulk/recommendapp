class AddPushIdToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :push_id, :string
  end
end
