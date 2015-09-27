class Item

  def self.activity_around_user_for_item(user, item)
    user_following_ids = user.following.ids

    at = Recommendation.arel_table
    conditions = at[:recommender_id].in(user_following_ids).or(at[:recommendee_id].in(user_following_ids))

    result = item.recommendations.where(conditions)
    result = result.joins("LEFT OUTER JOIN user_items 
      ON user_items.user_id = recommendations.recommendee_id 
      AND user_items.item_id = recommendations.item_id 
      AND user_items.item_type = recommendations.item_type"
    )
    result = result.select("recommendations.*", "user_items.like").distinct
  end

end