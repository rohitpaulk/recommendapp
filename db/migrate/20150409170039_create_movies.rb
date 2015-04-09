class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title
      t.string :year
      t.string :plot
      t.string :imdb_rating
      t.string :imdb_id
      t.string :poster_url

      t.timestamps null: false
    end
  end
end

