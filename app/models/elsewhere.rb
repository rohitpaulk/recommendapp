class Elsewhere < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :uid
  validates_presence_of :access_token
  validates_presence_of :provider
  validates_presence_of :user

  validates_uniqueness_of :uid, :scope => :provider
end