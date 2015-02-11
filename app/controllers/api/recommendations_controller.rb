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
        render plain: "Conflict", status: 409 and return
      end
    end
  end
end
