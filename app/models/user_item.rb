class UserItem < ActiveRecord::Base
	belongs_to :user
	belongs_to :item, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :item

  validates_uniqueness_of :user_id, scope: [:item_id, :item_type]
end
