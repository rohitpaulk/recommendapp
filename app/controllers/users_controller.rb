class UsersController < ActionController::Base
	def create
		auth_hash = request.env['omniauth.auth']
		render :json => auth_hash.to_json
 		#redirect_to(users_show_path)
	end
	def show
	end
end
