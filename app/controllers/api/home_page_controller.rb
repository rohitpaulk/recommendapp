class Api::HomePageController < ApplicationController

  before_filter :require_auth

  def initialize
    @categories = ["top_recommendations", "recent_recommendations"]
    @categories_name = ["Top Recommendations", "Recent recommendations"]
  end

  def movies
    render :json => home_data(Movie).to_json
  end

  def movies_show
    category_id = params[:category_id].to_i - 1
    render plain: "Invalid category id" and return if (category_id >= @categories.size || category_id < 0)
    render json: category_data(Movie, category_id)
  end

  def android_apps
    render :json => home_data(AndroidApp).to_json
  end

  def android_apps_show
    category_id = params[:category_id].to_i - 1
    render plain: "Invalid category id" and return if (category_id >= @categories.size || category_id < 0)
    render json: category_data(AndroidApp, category_id)
  end

  private
  #Helper methods. Might change!.
  def home_data(item_class)
    result = []
    result.append(format_data(item_class.top_recommendations(4), 1))
    result.append(format_data(item_class.recent_recommendations(4), 2))
    return result
  end

  def category_data(item_class, category_id)
    result = item_class.method(@categories[category_id]).call
    return format_data(result, category_id + 1).to_json
  end

  def format_data(items, category_id)
    return {
      :category_id    => category_id,
      :category_name  => @categories_name[category_id - 1],
      :items => items
    }
  end

end