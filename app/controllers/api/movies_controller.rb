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

  def show
    movie = Movie.find(params[:id])
    render :json => movie.to_json
  end

  def activity
    movie = Movie.find_by_id(params[:id])
    render plain: "Invalid movie id", status: 400 and return unless movie
    activity = movie.activity_around_user(@api_user)
    render json: include_activity_associations(activity)
  end

  private
  def include_activity_associations(activity)
    return activity.to_json(include: {
      :recommender => {
        :only => [:id, :name, :avatar_url]
      },
      :recommendee => {
        :only => [:id, :name, :avatar_url]
      },
      :request => {
        :except => [:created_at, :updated_at]
      }
    })
  end

end