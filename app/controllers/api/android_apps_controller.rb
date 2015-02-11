module Api
  class AndroidAppsController < ApplicationController

    before_filter :require_auth

    def index
      render :json => AndroidApp.all
    end

    # def create
    #   user_params = params.permit(
    #     :fb_uid,
    #     :name,
    #     :fb_access_token,
    #     :email
    #   )
    #   user = User.create_or_find_by_uid(user_params.delete(:fb_uid), user_params)

    #   render :json => user.to_json(:include => :elsewheres)
    # end
  end
end
