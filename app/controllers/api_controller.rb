class ApiController < ApplicationController
	protect_from_forgery except: :app_callback

	def app_callback
		user_params = params.permit(:uid, :name, :access_token, :email)
		if Elsewhere.exists?(:uid => user_params[:uid], :provider => 'facebook')
			user = Elsewhere.where(:uid => user_params[:uid], :provider => 'facebook').first.user
		else
			user = User.new
			user.email = user_params[:email]
			user.name = user_params[:name]
			user.elsewheres.build(
				:provider => 'facebook',
				:uid => user_params[:uid],
				:access_token => user_params[:access_token]
			)
			user.save
		end
		render :json => {
			"user" => user,
			"elsewhere" => user.elsewheres.first
		}.to_json
	end
end
