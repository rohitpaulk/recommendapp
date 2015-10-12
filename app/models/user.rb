class User < ActiveRecord::Base
  has_many :elsewheres, :dependent => :destroy

  has_many :user_items, :dependent => :destroy

  has_many :android_apps, :through => :user_items, :source => :item, :source_type => "AndroidApp"
  has_many :movies, :through => :user_items, :source => :item, :source_type => "Movie"

  has_many :recommendations, :foreign_key => :recommender_id, :dependent => :destroy
  has_many :received_recommendations, class_name: 'Recommendation', :foreign_key => :recommendee_id, dependent: :destroy
  has_many :recommended_android_apps, :through => :recommendations, :source => :item, :source_type => "AndroidApp"

  has_many :requests, :foreign_key => :requester_id, :dependent => :destroy
  has_many :received_requests, class_name: 'Request', foreign_key: :requestee_id, dependent: :destroy

  has_many :outgoing_relationships, class_name: 'UserFollower', foreign_key: :follower_id
  has_many :following, through: :outgoing_relationships, source: :following, class_name: "User", :dependent => :destroy

  has_many :incoming_relationships, class_name: 'UserFollower', foreign_key: :following_id
  has_many :followers, through: :incoming_relationships, source: :follower, class_name: "User", :dependent => :destroy

  validates_presence_of :api_access_token
  validates_presence_of :elsewheres

  before_validation :create_api_credentials, on: :create

  def create_api_credentials
    self.api_access_token ||= SecureRandom.hex(16)
  end

  def self.create_or_find_by_uid(uid, params)
    if Elsewhere.exists?(:uid => uid, :provider => 'facebook')
      elsewhere = Elsewhere.where(:uid => uid, :provider => 'facebook').first
      # Store the new access token
      elsewhere.access_token = params[:fb_access_token]
      elsewhere.save!
      user = Elsewhere.where(:uid => uid, :provider => 'facebook').first.user
      user.logged_in = true
      user.save!
      return user
    else
      user = User.new
      user.email = params[:email]
      user.name = params[:name]
      user.elsewheres.build(
        :provider => 'facebook',
        :uid => uid,
        :access_token => params[:fb_access_token]
      )
      user.save!
      return user
    end
  end

  def fetch_facebook_movies
    facebook_elsewhere = elsewheres.where(provider: 'facebook').first
    return unless facebook_elsewhere

    user = FbGraph::User.me(facebook_elsewhere.access_token)

    return user.movies
  end

  def fetch_facebook_friends
    facebook_elsewhere = elsewheres.where(provider: 'facebook').first
    return unless facebook_elsewhere
    user = FbGraph::User.me(facebook_elsewhere.access_token)

    user.friends.each do |fb_friend|
      fb_uid = fb_friend.raw_attributes['id']
      elsewhere = Elsewhere.where(provider: 'facebook', uid: fb_uid).first
      if elsewhere
        make_friends(elsewhere.user)
      end
    end
  end

  def has_completed_tour
    self.recommendations.exists?
  end

  def make_friends(user)
    unless self.following.include?(user)
      self.following << user
    end
    unless user.following.include?(self)
      user.following << self
    end
  end

  def update_facebook_avatar
    facebook_elsewhere = elsewheres.where(provider: 'facebook').first
    return unless facebook_elsewhere

    user = FbGraph::User.me(facebook_elsewhere.access_token).fetch
    self.avatar_url = user.picture
    self.save!
  end

  def update_movies_from_facebook
    fb_movies = fetch_facebook_movies

    i = 0
    fb_movies.each do |movie|
      movie_object = Movie.from_title(movie.name)
      self.movies << movie_object if (movie_object && !self.movies.include?(movie_object))
      i = i + 1
      break if i == 5
    end
  end

  def update_apps(apps)
    updated_apps = []

    apps.each do |item|
      app = AndroidApp.create_or_find_by_uid(item[:uid])
      if app
        unless android_apps.include?(app)
          android_apps.append(app)
          updated_apps.append(app)
        end
      end
    end

    save!
    return updated_apps
  end

  def send_notification(data)
    # Data is already in hash format
    GCM.send_notification(push_id, data) if push_id && logged_in
  end
end
