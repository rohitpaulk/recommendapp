module Api
  class RecommendationsController < ApplicationController

    before_filter :require_auth

    def index
      result = Recommendation

      if params[:recommendee_id]
        result = result.where(:recommendee_id => params[:recommendee_id])
      end

      if params[:recommender_id]
        result = result.where(:recommender_id => params[:recommender_id])
      end

      if params[:item_type]
        result = result.where(:item_type => params[:item_type])
      end

      result = result.all

      render :json => include_associations(result)
    end

    def create
      params["recommendee_emails"] ||= []
      params["recommendee_ids"] ||= []

      (item_class = Kernel.const_get(params['item_type'])) rescue render plain: "Invalid item type", :status => 400 and return
      render plain: "Invalid item id", status: 400 and return unless item = item_class.find_by_id(params['item_id'])
      render plain: "Recommendee list should be an array", status: 400 and return unless params["recommendee_ids"].is_a?(Array) and params["recommendee_emails"].is_a?(Array)

      new_recos = Recommendation.create_by_id_and_email(@api_user, item, params["recommendee_ids"], params["recommendee_emails"])
      render json: new_recos.to_json
    end

    def show
      reco = Recommendation.find(params[:id])
      render :json => include_associations(reco)
    end

    def update
      reco = Recommendation.find(params[:id])

      reco_params = params.permit(
        :status
      )
      if reco.update(reco_params)
        render :json => reco
      else
        render :json => { errors: reco.errors }, status: 409
      end
    end

    private
    def include_associations(reco)
      return reco.to_json(include: {
        :recommender => {
          :only => [:id, :name, :avatar_url]
        },
        :recommendee => {
          :only => [:id, :name, :avatar_url]
        },
        :item => {
          :except => [:created_at, :updated_at]
        }
      })
    end

  end
end
