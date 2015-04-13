class Movie < ActiveRecord::Base
  validates_presence_of :imdb_id, :title
  validates_uniqueness_of :imdb_id

  has_many :user_items, :as => :item
  has_many :users, :through => :user_items
end
