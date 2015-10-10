class EditorialNotification

  def initialize(message, title = nil, item_type = nil, item_id = nil)
    @type = "Editorial"
    @message = message
    @title = title if title
    @item_type = item_type if item_type
    @item_id = item_id if item_id
  end

end