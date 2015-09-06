class UserItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :item

  validates_uniqueness_of :user_id, scope: [:item_id, :item_type]

  def self.create_or_find_by_item(user, item)
    user_item = user.user_items.where(:item => item).first
    item_class = item.class.name
    if !user_item
      if item_class == 'Movie'
        user.movies << item
      elsif item_class == 'AndroidApp'
        user.android_apps << item
      end
      user_item = user.user_items.find_by_item_id(item.id)
    end
    return user_item
  end

end