class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def sign_in(user)
  	session[:current_user] = user.id
  end

  def signed_in?
  	session[:current_user]
  end

  def sign_out
  	session[:current_user] = nil
  end

  def current_user
  	User.find(session[:current_user])
  end
end
