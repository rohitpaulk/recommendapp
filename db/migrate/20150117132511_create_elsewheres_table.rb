class CreateElsewheresTable < ActiveRecord::Migration
  def change
    create_table :elsewheres do |t|
        t.string :provider
        t.string :uid
        t.string :access_token
        t.integer :user_id
    end
  end
end
