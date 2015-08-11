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

      result = result.all

      render :json => result
    end

    def create
      new_recos = Recommendation.create_by_id_and_email(@api_user, params)
      render :json => new_recos.to_json
    end

    def show
      reco = Recommendation.find(params[:id])
      render :json => reco.to_json(include: ["recommender", "recommendee", "item"])
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

  end
end
