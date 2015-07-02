class Api::MoviesController < ApplicationController
  before_filter :require_auth

  def index
    user = User.find(params[:user_id])

    movies = user.movies

    if movies.size < 5
      movies += Movie.popular_movies.take(5 - movies.size)
    end

    render json: movies.to_json
  end
end
