class User < ActiveRecord::Base
	has_many :elsewheres
	has_many :android_apps, :through => :user_items, :class_name =>

	validates_presence_of :api_access_token

	before_validation :create_api_credentials, on: :create

	def create_api_credentials
		self.api_access_token ||= SecureRandom.hex(16)
	end
end
