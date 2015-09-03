class Notification

  def initialize(type, name, item_type, item_id=nil)
    @type = type
    @name = name
    @item_type = item_type
    @item_id = item_id if item_id
  end

end