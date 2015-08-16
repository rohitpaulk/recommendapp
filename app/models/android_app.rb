class AndroidApp < ActiveRecord::Base
  validates_uniqueness_of :uid

  validates_presence_of :uid
  validates_presence_of :display_name

  has_many :user_items, :as => :item
  has_many :users, :through => :user_items

  def playstore_url
    "https://play.google.com/store/apps/details?id=#{uid}"
  end

  def self.create_or_find_by_uid(uid)
    app = AndroidApp.find_by_uid(uid)
    unless app
      api_app = MarketBot::Android::App.new(uid)
      api_app.update
      app = AndroidApp.create(app_params_from_api(api_app)) if api_app
    end
    app
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
