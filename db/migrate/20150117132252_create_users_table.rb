class CreateUsersTable < ActiveRecord::Migration
  def change
    create_table :users do |t|
        t.string :api_access_token
        t.string :name
        t.string :avatar_url
        t.timestamps
    end
  end
end
