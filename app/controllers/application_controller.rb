class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def require_auth
    api_access_token = params["api_access_token"]
    if User.exists?(:api_access_token => api_access_token)
      @api_user = User.find_by_api_access_token(api_access_token)
    else
      render plain: "Unauthorized", status: 401 and return
    end
  end

  def require_correct_user
    @user = User.find(params[:id])
    unless @user == @api_user
      render plain: "Unauthorized", status: 401
      return
    end
  end
end
