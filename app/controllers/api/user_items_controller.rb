class Api::UserItemsController < ApplicationController
  before_filter :require_auth, :require_correct_user

  def index
    user = User.find(params[:user_id])
    items = user.user_items
    render json: items.to_json
  end

  def create
    (item_class = Kernel.const_get(params[:item_type])) rescue render plain: "Invalid item type", :status => 400 and return
    render plain: "Invalid item id", status: 400 and return unless item = item_class.find_by_id(params[:item_id])

    user_item = UserItem.create_or_find_by_item(@user, item)

    user_item_params = params.permit(:like)

    if user_item.update(user_item_params)
      Recommendation.update_status(user_item)
      render json: user_item.to_json
    else
      render json: user_item.errors
    end
  end

end