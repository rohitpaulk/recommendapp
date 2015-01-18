class UsersController < ApplicationController
	def create
		auth_hash = request.env['omniauth.auth']
		if Elsewhere.exists?(:uid => auth_hash[:uid], :provider => 'facebook')
			sign_in(Elsewhere.where(:uid => auth_hash[:uid], :provider => 'facebook').first.user)
		else
			user = User.new
			user.elsewheres.build(
				:provider => 'facebook',
				:uid => auth_hash[:uid],
				:access_token => auth_hash[:credentials][:token]
			)
			user.save
			sign_in(user)
		end
		redirect_to users_show_path(current_user)
	end
	def show

	end
end
