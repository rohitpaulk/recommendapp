class Api::HomePageController < ApplicationController

  before_filter :require_auth, :init_categories

  def init_categories
    @categories = [
      Category.new("Popular around you", "top_recommendations_around_user", [@api_user]),
      Category.new("Recent around you", "recent_recommendations_around_user", [@api_user]),
      Category.new("Popular overall", "top_recommendations", []),
      Category.new("Recent overall", "recent_recommendations", [])
    ]
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

  def home_data(item_class)
    result = []
    result.append(format_data(item_class.top_recommendations_around_user(@api_user, 4), 0))
    result.append(format_data(item_class.recent_recommendations_around_user(@api_user, 4), 1))
    result.append(format_data(item_class.top_recommendations(4), 2))
    result.append(format_data(item_class.recent_recommendations(4), 3))
    return result
  end

  def category_data(item_class, category_id)
    method = @categories[category_id].method_name
    args = @categories[category_id].arguments

    result = item_class.send(method, *args)
    return format_data(result, category_id).to_json
  end

  def format_data(items, category_id)
    return {
      :category_id    => category_id + 1,
      :category_name  => @categories[category_id].category_name,
      :items => items
    }
  end

  class Category
    attr_reader :category_name, :method_name, :arguments

    def initialize(category_name, method_name, arguments)
      @category_name = category_name
      @method_name = method_name
      @arguments = arguments
    end

  end
end