class AddDetailsToAndroidApps < ActiveRecord::Migration
  def change
    add_column :android_apps, :rating, :string, after: :display_name
    add_column :android_apps, :description, :string, after: :rating
  end
end
