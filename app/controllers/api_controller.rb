class ApiController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_action :require_auth, except: :users_upsert

	def require_auth
		api_access_key = params["api_access_key"]
		if User.exists?(:api_access_key => api_access_key)
			@user = User.find(:api_access_key => api_access_key)
		else
			render plain: "Unauthorized", status: 401 and return
		end
	end

	def users_upsert
		user_params = params.permit(:fb_uid, :name, :fb_access_token, :email)
		if Elsewhere.exists?(:uid => user_params[:fb_uid], :provider => 'facebook')
			user = Elsewhere.where(:uid => user_params[:fb_uid], :provider => 'facebook').first.user
		else
			user = User.new
			user.email = user_params[:email]
			user.name = user_params[:name]
			user.elsewheres.build(
				:provider => 'facebook',
				:uid => user_params[:uid],
				:access_token => user_params[:fb_access_token]
			)
			user.save
		end
		render :json => {
			"user" => user,
			"elsewhere" => user.elsewheres.first
		}.to_json
	end

	def user_apps_upsert
		apps = params["apps"]
	end
end
