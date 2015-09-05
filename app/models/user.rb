class User < ActiveRecord::Base
  has_many :elsewheres

  has_many :user_items
  has_many :android_apps, :through => :user_items, :source => :item, :source_type => "AndroidApp"
  has_many :movies, :through => :user_items, :source => :item, :source_type => "Movie"

  has_many :recommendations, :foreign_key => :recommender_id
  has_many :recommended_android_apps, :through => :recommendations, :source => :item, :source_type => "AndroidApp"

  has_many :requests, :foreign_key => :requester_id

  has_many :outgoing_relationships, class_name: 'UserFollower', foreign_key: :follower_id
  has_many :following, through: :outgoing_relationships, source: :following, class_name: "User"

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
      return Elsewhere.where(:uid => uid, :provider => 'facebook').first.user
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

    user.friends.map { |fb_friend|
      fb_uid = fb_friend.raw_attributes['id']
      elsewhere = Elsewhere.where(provider: 'facebook', uid: fb_uid).first
      if elsewhere then elsewhere.user else nil end
    }.compact
  end

  def has_completed_tour
    self.recommendations.exists?
  end

  def update_facebook_friends
    self.following << fetch_facebook_friends
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

    fb_movies.each do |movie|
      movie_object = Movie.from_title(movie.name)
      self.movies << movie_object if (movie_object && !self.movies.include?(movie_object))
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
    GCM.send_notification(push_id, data) if push_id
  end
end
