class CreateAndroidApps < ActiveRecord::Migration
  def change
    create_table :android_apps do |t|
      t.string :uid
      t.string :display_name
      t.string :icon_url
      t.timestamps null: false
    end
  end
end
