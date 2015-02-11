module Api
  class RecommendationsController < ApplicationController

    before_filter :require_auth

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
        render plain: "Bad Request!!", status: 400 and return
      end
    end
  end
end
