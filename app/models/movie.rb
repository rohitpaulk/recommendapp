class Movie < ActiveRecord::Base
  validates_presence_of :imdb_id, :title
  validates_uniqueness_of :imdb_id

  has_many :user_items, :as => :item
  has_many :users, :through => :user_items

  def self.from_title(title)
    if Movie.exists?(title: title)
      Movie.find_by_title(title)
    else
      Enceladus.connect("eace344fe11061cf0a80c99ddd40c34a",
        {
          include_image_language: "en",
          language: "en,null",
          include_adult: true
        })
      api_movie = Enceladus::Movie.find_by_title(title).first
      return nil unless api_movie
      create_movie_from_api(api_movie)
    end
  end

  def self.popular_movies
    Enceladus.connect("eace344fe11061cf0a80c99ddd40c34a",
      {
        include_image_language: "en",
        language: "en,null",
        include_adult: true
      })

    collection = Enceladus::Movie.popular
    api_movies = collection.results_per_page[0]
    Enumerator.new do |e|
      api_movies.each { |api_movie|
        movie = Movie.find_by_title(api_movie.original_title)
        unless movie
          movie = create_movie_from_api(api_movie)
        end
        e.yield movie
      }
    end
  end

  def self.create_movie_from_api(api_movie)
    movie = Movie.create!(
      title:       api_movie.original_title,
      year:        api_movie.release_date,
      plot:        api_movie.overview,
      imdb_id:     api_movie.id,  #This isn't imdb id. TODO
      imdb_rating: api_movie.vote_average,  #Not imdb rating. TODO
      poster_url:  api_movie.poster_urls[1] #TODO
    )
  end
end