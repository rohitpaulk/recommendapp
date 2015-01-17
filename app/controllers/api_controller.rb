class ApiController < ApplicationController
	protect_from_forgery except: :app_callback

	def app_callback
		user_params = params.permit(:uid, :access_token)
		user = User.new
		user.elsewheres.build(:provider => 'facebook', :uid => user_params[:uid], :access_token => user_params[:access_token])
		user.save
		render :json => {
			"user" => user,
			"elsewhere" => user.elsewheres.first
		}.to_json
	end
end
