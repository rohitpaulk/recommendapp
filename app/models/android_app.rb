class AndroidApp < ActiveRecord::Base
  validates_uniqueness_of :uid

  validates_presence_of :uid
  validates_presence_of :display_name

  has_many :user_items, :as => :item
  has_many :users, :through => :user_items
  has_many :recommendations, :as => :item

  def playstore_url
    "https://play.google.com/store/apps/details?id=#{uid}"
  end
end
