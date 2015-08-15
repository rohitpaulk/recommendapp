class Api::FriendsController < ApplicationController
  before_filter :require_auth

  def index
    user = User.find(params[:user_id])

    # If has_item is provided, we need both.
    if params[:item_type].present? ^ params[:item_id].present?
      render plain: "Provide a pair of parameters, item_id and item_type", status: 400 and return
    end

    # If item_type exists, should be valid
    unless [nil, 'Movie', 'AndroidApp'].include?(params[:item_type])
      render plain: "Invalid item_type", status: 422 and return
    end

    result = user.following

    if params[:item_type] && params[:item_id]
      result = result.each.map do |follower|
        has_item = follower.user_items.where(
                                  :item_type => params[:item_type], 
                                  item_id: params[:item_id]
                                ).exists?
        has_been_recommended = user.recommendations.where(
                                  :recommendee => follower, 
                                  :item_type => params[:item_type], 
                                  :item_id => params[:item_id]
                                ).exists?

        follower = follower.serializable_hash
        follower[:has_item] = has_item
        follower[:has_been_recommended] = has_been_recommended
        follower
      end
    end

    render :json => result
  end
end
