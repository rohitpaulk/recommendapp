class Notification

  def initialize(type, name, item_type, item_id=nil, like=nil)
    @type = type
    @name = name
    @item_type = item_type
    @item_id = item_id if item_id
    @like = like if like
  end

end