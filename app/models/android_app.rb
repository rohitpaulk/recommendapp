class AndroidApp < ActiveRecord::Base
	validate_uniqueness_of :uid

	def playstore_url
		"https://play.google.com/store/apps/details?id=#{uid}"
	end
end
