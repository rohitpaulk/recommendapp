class Api::UsersController < ApplicationController
  before_filter :require_auth, :except => :create
  before_filter :require_correct_user, only: [:update]

  def index
    render :json => User.all
  end

  def show
    user = User.find(params[:id])
    render :json => user.to_json(:include => :elsewheres)
  end

  def create
    user_params = params.permit(
      :fb_uid,
      :name,
      :fb_access_token,
      :email
    )
    user = User.create_or_find_by_uid(user_params.delete(:fb_uid), user_params)

    user.update_facebook_friends
    user.update_facebook_avatar
    user.update_movies_from_facebook

    render :json => user.to_json(:include => :elsewheres)
  end

  def update
    user_params = params.permit(
      :push_id
    )
    if @user.update(user_params)
      render :json => @user
    else
      render :json => { errors: @user.errors }, status: 409
    end
  end
end
