class Api::FriendsController < ApplicationController
  before_filter :require_auth

  def index
    user = User.find(params[:user_id])

    # If item_type exists, should be valid
    unless [nil, 'Movie', 'AndroidApp'].include?(params[:item_type])
      render plain: "Invalid item_type", status: 422 and return
    end

    result = user.following.order(:name)

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
    elsif params[:item_type]
      result = result.each.map do |follower|
        has_been_requested = user.requests.where(
                                :requestee => follower,
                                :item_type => params[:item_type],
                                :status => ['pending', 'sent']
                              ).exists?
        follower = follower.serializable_hash
        follower[:has_been_requested] = has_been_requested
        follower
      end
    end

    render :json => result
  end
end
