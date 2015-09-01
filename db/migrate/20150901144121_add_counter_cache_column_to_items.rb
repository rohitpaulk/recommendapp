class AddCounterCacheColumnToItems < ActiveRecord::Migration
  def up
    add_column :movies, :recommendations_count, :integer, :count => 0
    add_column :android_apps, :recommendations_count, :integer, :count => 0

    Movie.reset_column_information
    Movie.all.each do |movie|
      movie.update_column(:recommendations_count, movie.recommendations.count)
    end

    AndroidApp.reset_column_information
    AndroidApp.all.each do |app|
      app.update_column(:recommendations_count, app.recommendations.count)
    end
  end

  def down
    remove_column :movie, :recommendations_count
    remove_column :apps, :recommendations_count
  end
end
