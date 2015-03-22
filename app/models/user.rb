class User < ActiveRecord::Base
  has_many :elsewheres

  has_many :user_items
  has_many :android_apps, :through => :user_items, :source => :item, :source_type => "AndroidApp"

  has_many :recommendations, :foreign_key => :recommender_id
  has_many :recommended_android_apps, :through => :recommendations, :source => :item, :source_type => "AndroidApp"

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

  def fetch_facebook_friends
    facebook_elsewhere = elsewheres.where(provider: 'facebook').first
    return unless facebook_elsewhere
    user = FbGraph::User.me(facebook_elsewhere.access_token)

    user.friends.map do |fb_friend|
      fb_uid = fb_friend.raw_attributes['id']
      Elsewhere.where(provider: 'facebook', uid: fb_uid).first.user
    end
  end

  def update_facebook_friends
    self.following << fetch_facebook_friends
  end

  def update_apps(apps)
    updated_apps = []

    apps.each do |item|
      if AndroidApp.exists?(:uid => item[:uid])
        existing_app = AndroidApp.find_by_uid(item[:uid])
        unless android_apps.include?(existing_app)
          android_apps.append(existing_app)
          updated_apps.append(existing_app)
        end
        if reco = Recommendation.where(:recommendee => self, :item => existing_app).first
          reco.status = 'successful'
          reco.save!
        end
      else
        name = item[:display_name]
        name.encode!('UTF-8','binary',invalid: :replace, undef: :replace, replace: '')
        new_app = AndroidApp.create(:uid => item[:uid], :display_name => name)

        android_apps.append(new_app)
        updated_apps.append(new_app)
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
