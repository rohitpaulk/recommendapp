module Api
  class UsersController < ApplicationController

    before_filter :require_auth, :except => :create
    def index
      render :json => User.all
    end

    def create
      user_params = params.permit(
        :fb_uid,
        :name,
        :fb_access_token,
        :email
      )
      user = User.create_or_find_by_uid(user_params.delete(:fb_uid), user_params)

      render :json => user.to_json(:include => :elsewheres)
    end

    def android_apps_index
      user = User.find(params[:id])
      render :json => user.android_apps.to_json
    end

    def android_apps_create
      user = User.find(params[:id])
      render plain: "Unauthorized", status: 401 and return unless user == @user

      user.update_apps(params['apps'])

      render :json => user.android_apps.to_json
    end
  end
end