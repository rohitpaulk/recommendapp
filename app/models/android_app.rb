class AndroidApp < ActiveRecord::Base
	def playstore_url
		"https://play.google.com/store/apps/details?id=#{uid}"
	end
end
