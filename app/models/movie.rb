class Movie < ActiveRecord::Base
  validates_presence_of :imdb_id, :title
  validates_uniqueness_of :imdb_id

  has_many :user_items, :as => :item
  has_many :users, :through => :user_items

  def self.from_title(title)
    if Movie.exists?(title: title)
      Movie.find_by_title(title)
    else
      response = Omdb::Api.new.fetch(title)[:movie]
      return nil unless response
      movie = Movie.create!(
        title:       response.title,
        year:        response.year,
        plot:        response.plot,
        imdb_id:     response.imdb_id,
        imdb_rating: response.imdb_rating,
        poster_url:  response.poster
      )
    end
  end

  def self.popular_movies
    Enumerator.new do |e|
      ['Terminator', 'Interstellar', 'Dark Knight', 'Titanic', 'Spiderman'].each { |title|
        e.yield Movie.from_title(title)
      }
    end
  end
end
