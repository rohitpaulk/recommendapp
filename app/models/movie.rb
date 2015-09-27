class Movie < ActiveRecord::Base
  validates_presence_of :imdb_id, :title
  validates_uniqueness_of :imdb_id

  has_many :user_items, :as => :item, dependent: :destroy
  has_many :users, :through => :user_items
  has_many :recommendations, :as => :item, dependent: :destroy

  def self.from_title(title)
    if Movie.exists?(title: title)
      Movie.find_by_title(title)
    else
      api_movie = Enceladus::Movie.find_by_title(title).first
      return nil unless api_movie
      unless movie = Movie.find_by_imdb_id(api_movie.id)
        movie = Movie.create!(movie_params_from_api(api_movie))
      end
      movie
    end
  end

  def self.search(title, page = 1)
    movies = []
    collection = Enceladus::Movie.find_by_title(title)
    while page <= collection.total_pages && movies.length < 20
      collection.current_page = page
      collection.results_per_page[page - 1].each do |api_movie|
        searched_movie = Movie.new(movie_params_from_api(api_movie))
        movie = Movie.where(:imdb_id => searched_movie.imdb_id).first
        unless movie
          searched_movie.save
          movie = searched_movie
        end
        movies.append(movie)
      end
      page += 1
    end
    return movies
  end

  def self.popular_movies
    collection = Enceladus::Movie.popular
    api_movies = collection.results_per_page[0]
    Enumerator.new do |e|
      api_movies.each { |api_movie|
        movie = Movie.find_by_imdb_id(api_movie.id)
        unless movie
          movie = Movie.create!(movie_params_from_api(api_movie))
        end
        e.yield movie
      }
    end
  end

  def self.top_recommendations(count = -1)
    result = Movie.where.not(recommendations_count: nil).order(recommendations_count: :desc)
    if count > 0
      result = result.limit(count)
    end
    result.distinct
  end

  def self.recent_recommendations(count = -1)
    # find all unique recommende movies in a subquery,
    # then order them by recommendation date.
    # See http://stackoverflow.com/questions/32775220/rails-distinct-on-after-a-join/32787503#32787503
    # for a better way.
    inner_query = Movie.joins(:recommendations)
      .select("DISTINCT ON (movies.id) movies.*, recommendations.updated_at as date")

    result = Movie.from("(#{inner_query.to_sql}) as unique_recommendations")
      .select("unique_recommendations.*")
      .order("unique_recommendations.date DESC")

    if(count > 0)
      # should be in subquery. But gives different result then.
      result = result.limit(count)
    end

    result
  end

  def self.recommendations_around_user(user)
    #Option 1
    at = Recommendation.arel_table
    ids = User.first.following.select(:id)
    Movie.joins(:recommendations)
    .where(at[:recommender_id].in(ids).or(at[:recommendee_id].in(ids)))

    #Option 2
    # Movie.joins(:recommendations)
    # .where(
    #     Movie.joins(:recommendations)
    #     .where(recommendations: {:recommender => user.following})
    #     .where(recommendations: {:recommendee => user.following})
    #     .where_values.reduce(:or)
    # ).distinct

  end

  private
  def self.movie_params_from_api(api_movie)
    return {
      title:       api_movie.original_title,
      year:        api_movie.release_date,
      plot:        api_movie.overview,
      imdb_id:     api_movie.id,  #This isn't imdb id. TODO
      imdb_rating: api_movie.vote_average,  #Not imdb rating. TODO
      poster_url:  api_movie.poster_urls[1] #TODO
    }
  end

end
