class Recommendation < ActiveRecord::Base
  has_one :request, :foreign_key => "response_id"
  belongs_to :recommendee, :class_name => "User"
  belongs_to :recommender, :class_name => "User"
  belongs_to :item, :polymorphic => true, :counter_cache => true

  validates_presence_of :recommendee
  validates_presence_of :recommender
  validates_presence_of :item
  validates_presence_of :status
  validates_inclusion_of :status, in: ["pending", "sent", "seen", "successful"]

  validates_uniqueness_of :item_id, scope: [:recommendee, :recommender, :item_type]

  after_create :send_notification, :update_request

  class RecursionValidator < ActiveModel::Validator
    def validate(record)
      if record.recommender_id == record.recommendee_id
        record.errors[:base] << "You can't recommend items to yourself!"
      end
    end
  end

  validates_with RecursionValidator

  before_validation :set_pending_status

  def self.create_by_id_and_email(recommender, item, recommendee_ids, recommendee_emails)
    new_recommendations = []

    recommendee_ids.each do |id|
      recommendee = User.find_by_id(id)
      if recommendee
        new_recommendations.append(create_recommendation(recommender, recommendee, item))
      else
        new_recommendations.append(format_error(["Invalid recommendee id"]))
      end
    end
    recommendee_emails.each do |email|
      recommendee = User.find_by_email(email)
      if recommendee
        new_recommendations.append(create_recommendation(recommender, recommendee, item))
        #TODO - Make them friends.
      else
        #TODO - New user. Send email with new recommendation.
      end
    end
    return new_recommendations
  end

  def set_pending_status
    self.status ||= 'pending'
  end

  def send_notification
    recommendee.send_notification(self.serializable_hash(:include => ["recommender", "recommendee"]))
    self.status = 'sent'
    save!
  end

  private
  def self.create_recommendation(recommender, recommendee, item)
    reco = Recommendation.new(
      :recommender => recommender,
      :recommendee => recommendee,
      :item => item
    )
    unless reco.save
      return format_error(reco.errors.full_messages)
    end
    return reco
  end

  def self.format_error(msg)
    return { :errors => msg }
  end

  def update_request
    request = Request.where(
        :requestee => recommender,
        :requester => recommendee,
        :item_type => item_type
      ).first
    if request.present?
      request.response = self
      request.save
    end
  end
end
