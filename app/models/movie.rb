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
      Enceladus::Configuration::Image.instance.setup!
      movie = Enceladus::Movie.find_by_title(title).first
      return nil unless movie
      movie = Movie.create!(
        title:       movie.original_title,
        year:        movie.release_date,
        plot:        movie.overview,
        imdb_id:     movie.id,  #This isn't imdb id. TODO
        imdb_rating: movie.vote_average,  #Not imdb rating. TODO
        poster_url:  Enceladus::Configuration::Image.instance.url_for(
          "logo", movie.poster_path)[-1] #TODO
      )
    end
  end

  def self.popular_movies
    Enceladus.connect("eace344fe11061cf0a80c99ddd40c34a",
      {
        include_image_language: "en",
        language: "en,null",
        include_adult: true
      })
    Enceladus::Configuration::Image.instance.setup!

    collection = Enceladus::Movie.popular
    movies = collection.results_per_page[0]
    Enumerator.new do |e|
      movies.each { |movie|
        puts movie.original_title
        e.yield movie
      }
    end
  end
end
