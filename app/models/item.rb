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

  def self.top_recommendations(klass, count = -1)
    result = klass.where.not(recommendations_count: nil).order(recommendations_count: :desc)
    if count > 0
      result = result.limit(count)
    end
    result.distinct
  end

  def self.top_recommendations_around_user(klass, user, count = -1)
    table_name = klass.table_name

    result = klass.joins(:recommendations).joins(:recommendations => :recommender)
    result = result.where(:recommendations => { :recommender_id => user.following } )
    result = result.select(
      "count(DISTINCT recommendations.item_id || ' ' || recommendations.recommender_id) AS friends_rec_count,
      #{table_name}.*,
      array_agg( DISTINCT users.avatar_url) AS profile_pics"
    ) #only postgresql
    result = result.group("#{table_name}.id")
    result = result.order("friends_rec_count DESC")

    if count > 0
      result = result.limit(count)
    end
    result
  end

  def self.recent_recommendations(klass, count = -1)
    # find all unique recommended movies in a subquery,
    # then order them by recommendation date.
    # See http://stackoverflow.com/questions/32775220/rails-distinct-on-after-a-join/32787503#32787503
    # for alternatives.
    table_name = klass.table_name

    inner_query = klass.joins(:recommendations)
    inner_query = inner_query.select("DISTINCT ON (#{table_name}.id)
      #{table_name}.*,
      recommendations.updated_at as date"
    )

    result = klass.from("(#{inner_query.to_sql}) as unique_recommendations")
    result = result.select("unique_recommendations.*")
    result = result.order("unique_recommendations.date DESC")

    if count > 0
      # should be in subquery. But gives different result then.
      result = result.limit(count)
    end
    result
  end

  def self.recent_recommendations_around_user(klass, user, count = -1)
    table_name = klass.table_name

    result = klass.joins(:recommendations).joins(:recommendations => :recommender)
    result = result.where(:recommendations => { :recommender_id => user.following } )
    result = result.select("max(recommendations.updated_at) as date,
      #{table_name}.*,
      array_agg( DISTINCT users.avatar_url ) AS profile_pics"
    )
    result = result.group("#{table_name}.id")
    result = result.order("date DESC")

    if count > 0
      result = result.limit(count)
    end
    result
  end

end