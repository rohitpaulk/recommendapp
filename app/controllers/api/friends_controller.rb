class Api::FriendsController < ApplicationController
  before_filter :require_auth

  def index
    user = User.find(params[:user_id])

    # If has_item is provided, we need both.
    if params[:has_item_type].present? ^ params[:has_item_id].present?
      render plain: "Provide a pair of parameters, has_item_id and has_item_type", status: 400 and return
    end

    # If has_item_type exists, should be valid
    unless [nil, 'AndroidApp'].include?(params[:has_item_type])
      render plain: "Invalid has_item_type, should be AndroidApp", status: 400 and return
    end

    result = user.following

    if params[:has_item_type] && params[:has_item_id]
      result = result.each.map do |user|
        has_item = !user.android_apps.where(id: params[:has_item_id]).empty?
        user = user.serializable_hash
        user[:has_item] = has_item
        user
      end
    end

    render :json => result
  end
end
