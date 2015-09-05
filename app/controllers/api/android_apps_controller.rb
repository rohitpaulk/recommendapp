class Api::AndroidAppsController < ApplicationController
  before_filter :require_auth
  before_filter :require_correct_user, only: [:create, :batch_delete]

  def index
    if params[:user_id]
      user = User.find(params[:user_id])
      render :json => user.android_apps.to_json
    else
      render :json => AndroidApp.all
    end
  end

  def create
    render plain: "Provide an array of apps.", status: 400 and return unless params[:apps].is_a?(Array)

    updated_apps = @user.update_apps(params['apps'])
    render :json => updated_apps.to_json
  end

  def batch_delete
    render plain: "Provide an array of apps.", status: 400 and return unless params[:uid]

    app = AndroidApp.find_by_uid(params[:uid])

    if @user.android_apps.include?(app)
      @user.android_apps.delete(app)
    end

    render :plain => "Deleted"
  end

  def show
    app = AndroidApp.find(params[:id])
    render :json => app.to_json
  end
end
