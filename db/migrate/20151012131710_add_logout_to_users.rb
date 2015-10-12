class AddLogoutToUsers < ActiveRecord::Migration
  def up
    add_column :users, :logged_in, :boolean, :default => true
    User.update_all(logged_in: true)
  end

  def down
    remove_column :users, :logged_in
  end
end
