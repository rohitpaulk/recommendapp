class Recommendation < ActiveRecord::Base
	belongs_to :recommendee, :class_name => "User"
	belongs_to :recommender, :class_name => "User"
	belongs_to :item, :polymorphic => true

  validates_presence_of :recommendee
  validates_presence_of :recommender
  validates_presence_of :item
end
