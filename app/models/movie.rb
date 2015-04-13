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
      movie = Movie.create!(
        title:       response.title,
        year:        response.year,
        plot:        response.plot,
        imdb_id:     response.imdb_id,
        imdb_rating: response.imdb_rating,
        poster_url:  response.poster
      )
      return movie
    end
  end
end
