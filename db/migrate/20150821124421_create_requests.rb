class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :requestee, references: :users
      t.references :requester, references: :users
      t.string :item_type
      t.string :status
      t.timestamps null: false
    end
  end
end
