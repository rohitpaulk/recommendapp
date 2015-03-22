class UserFollower < ActiveRecord::Base
	belongs_to :follower, class_name: "User"
	belongs_to :following, class_name: "User"

	validates_presence_of :follower
	validates_presence_of :following
	validates_inclusion_of :derived_from, in: ['facebook'], allow_blank: true

	validates_uniqueness_of :follower_id, scope: [:following_id]
end
