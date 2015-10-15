class AddTrailerToMovies < ActiveRecord::Migration
  def up
    add_column :movies, :trailer_link, :string
    Movie.find_each do |movie|
      api_movie = Enceladus::Movie.find(movie.imdb_id)
      if api_movie.youtube_trailers.first
        movie.trailer_link = api_movie.youtube_trailers.first.link
        movie.save(:validate => false)
      end
    end
  end

  def down
    remove_column :movies, :trailer_link
  end
end
