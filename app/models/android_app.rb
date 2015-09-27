class AndroidApp < ActiveRecord::Base
  validates_uniqueness_of :uid

  validates_presence_of :uid
  validates_presence_of :display_name

  has_many :user_items, :as => :item, dependent: :destroy
  has_many :users, :through => :user_items
  has_many :recommendations, :as => :item, dependent: :destroy

  def playstore_url
    "https://play.google.com/store/apps/details?id=#{uid}"
  end

  def self.create_or_find_by_uid(uid)
    app = AndroidApp.find_by_uid(uid)
    unless app
      api_app = MarketBot::Android::App.new(uid)
      api_app.update rescue MarketBot::ResponseError and return nil
      app = AndroidApp.create(app_params_from_api(api_app)) if api_app
    end
    app
  end

  def self.search(query)
    return AndroidApp.where("LOWER(display_name) LIKE ?", "%#{query.downcase}%")
    # api_apps = MarketBot::Android::SearchQuery.new(query)
    # api_apps.update
    # api_apps.results.each do |api_app|
    #   puts api_app
    #   uid = api_app[:market_id] #weird
    #   app = create_or_find_by_uid(uid)
    #   puts app
    # end
  end

  def self.top_recommendations(count = -1)
    result = AndroidApp.where.not(recommendations_count: nil).order(recommendations_count: :desc)
    if count > 0
      result = result.limit(count)
    end
    result.distinct
  end

  def self.recent_recommendations(count = -1)
    inner_query = AndroidApp.joins(:recommendations)
      .select("DISTINCT ON (android_apps.id) android_apps.*, recommendations.updated_at as date")

    result = AndroidApp.from("(#{inner_query.to_sql}) as unique_recommendations")
      .select("unique_recommendations.*")
      .order("unique_recommendations.date DESC")

    if(count > 0)
      result = result.limit(count)
    end
    
    result
  end

  def activity_around_user(user)
    Item.activity_around_user_for_item(user, self)
  end

  private
  def self.app_params_from_api(api_app)
    return {
      uid:            api_app.app_id,
      display_name:   api_app.title,
      icon_url:       api_app.banner_icon_url,
      rating:         api_app.rating,
      description:    Nokogiri::HTML(api_app.description).text
    }
  end
end
