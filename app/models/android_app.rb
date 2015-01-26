class AndroidApp < ActiveRecord::Base
	validates_uniqueness_of :uid

	has_many :user_items, :as => :item
	has_many :users, :through => :user_items

	def playstore_url
		"https://play.google.com/store/apps/details?id=#{uid}"
	end
end
