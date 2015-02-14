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
      recommendee = User.find(params["recommendee_id"])
      item_class = Kernel.const_get(params['item_type'])
      item = item_class.find(params['item_id'])
      reco = Recommendation.new(
        :recommender => @user,
        :recommendee => recommendee,
        :item => item
      )
      if reco.save
        render :json => reco
      else
        render json: { errors: reco.errors }, status: 409 and return
      end
    end

    def show
      reco = Recommendation.find(params[:id])
      render :json => reco
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
