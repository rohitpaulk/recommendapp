class ApiController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_action :require_auth, except: :users_upsert



	# def users_upsert
	# 	user_params = params.permit(:fb_uid, :name, :fb_access_token, :email)
	# 	if Elsewhere.exists?(:uid => user_params[:fb_uid], :provider => 'facebook')
	# 		user = Elsewhere.where(:uid => user_params[:fb_uid], :provider => 'facebook').first.user
	# 	else
	# 		user = User.new
	# 		user.email = user_params[:email]
	# 		user.name = user_params[:name]
	# 		user.elsewheres.build(
	# 			:provider => 'facebook',
	# 			:uid => user_params[:fb_uid],
	# 			:access_token => user_params[:fb_access_token]
	# 		)
	# 		user.save
	# 	end
	# 	render :json => {
	# 		"user" => user,
	# 		"elsewhere" => user.elsewheres.first
	# 	}.to_json
	# end

	def user_apps_upsert
		apps = params["apps"]
		android_apps = []
		apps.each do |app|
			if AndroidApp.exists?(:uid => app['uid'])
				android_apps.append(AndroidApp.find_by_uid(app['uid']))
			else
				name = app[:display_name]
				name.encode!('UTF-8','binary',invalid: :replace, undef: :replace, replace: '')
				new_app = AndroidApp.create(:uid => app['uid'], :display_name => app['display_name'])
				android_apps.append(new_app)
			end
		end
		@user.android_apps = android_apps
		@user.save
		render :json => @user.android_apps
	end

	def recommendations_create
		recommendee = User.find(params["recommendee_id"])
		app = AndroidApp.find_by_uid(params['app_uid'])
		reco = Recommendation.new(
			:recommender => @user,
			:recommendee => recommendee,
			:item => app
		)
		if reco.save
			render :json => reco
		else
			render plain: "Bad Request!!", status: 400 and return
		end
	end

	def recommendations_list
		recommendations = Recommendation.where(recommendee_id: @user.id)
		render :json => recommendations
	end
end
