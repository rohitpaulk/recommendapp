class User < ActiveRecord::Base
	has_many :elsewheres

	has_many :user_items
	has_many :android_apps, :through => :user_items, :source => :item, :source_type => "AndroidApp"

	has_many :recommendations, :foreign_key => :recommender_id
	has_many :recommended_android_apps, :through => :recommendations, :source => :item, :source_type => "AndroidApp"

	validates_presence_of :api_access_token
	validates_presence_of :elsewheres

	before_validation :create_api_credentials, on: :create

	def create_api_credentials
		self.api_access_token ||= SecureRandom.hex(16)
	end

	def self.create_or_find_by_uid(uid, params)
		if Elsewhere.exists?(:uid => uid, :provider => 'facebook')
		  return Elsewhere.where(:uid => uid, :provider => 'facebook').first.user
		else
		  user = User.new
		  user.email = params[:email]
		  user.name = params[:name]
		  user.elsewheres.build(
		    :provider => 'facebook',
		    :uid => uid,
		    :access_token => params[:fb_access_token]
		  )
		  user.save!
		  return user
		end
	end

	def update_apps(apps)
		apps.each do |item|
			if AndroidApp.exists?(:uid => item[:uid])
				existing_app = AndroidApp.find_by_uid(item[:uid])
				unless android_apps.include?(existing_app)
		    	android_apps.append(existing_app)
		    end
		  else
		  	name = item[:display_name]
		    name.encode!('UTF-8','binary',invalid: :replace, undef: :replace, replace: '')
		    new_app = AndroidApp.create(:uid => item[:uid], :display_name => name)
		    android_apps.append(new_app)
		  end
		end

		save!
	end

	def send_notification(data)
		# Data is already in JSON format
		GCM.send_notification(push_id, data) if push_id
	end
end
