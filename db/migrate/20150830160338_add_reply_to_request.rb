class AddReplyToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :response_id, :integer
    add_index :requests, :response_id, :unique => true
  end
end