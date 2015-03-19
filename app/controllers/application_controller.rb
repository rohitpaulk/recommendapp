class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def require_auth
    api_access_token = params["api_access_token"]
    if User.exists?(:api_access_token => api_access_token)
      @user = User.find_by_api_access_token(api_access_token)
    else
      render plain: "Unauthorized", status: 401 and return
    end
  end
end
