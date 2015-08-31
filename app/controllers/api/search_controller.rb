class Api::SearchController < ApplicationController
  before_filter :require_auth

  def index
    item_types = ["Movie", "AndroidApp"] #TODO - make global
    search_params = params.permit(
        :item_type,
        :q
      )
    if params.has_key?(:item_type)
      render plain: "Invalid item type", status: 422 and return if !item_types.include? params[:item_type]
      item_class = Kernel.const_get(params[:item_type])
      result = item_class.search(params[:q])
    else
      movies = Movie.search(params[:q]).first(4)
      apps = AndroidApp.search(params[:q]).first(4)
      result = {
        :movies => movies,
        :apps => apps
      }
    end
    render json: result.to_json
  end

end