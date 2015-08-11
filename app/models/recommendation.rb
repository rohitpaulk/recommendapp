class Recommendation < ActiveRecord::Base
  belongs_to :recommendee, :class_name => "User"
  belongs_to :recommender, :class_name => "User"
  belongs_to :item, :polymorphic => true

  validates_presence_of :recommendee
  validates_presence_of :recommender
  validates_presence_of :item
  validates_presence_of :status
  validates_inclusion_of :status, in: ["pending", "sent", "seen", "successful"]

  validates_uniqueness_of :item_id, scope: [:recommendee, :recommender, :item_type]

  after_create :send_notification

  class RecursionValidator < ActiveModel::Validator
    def validate(record)
      if record.recommender_id == record.recommendee_id
        record.errors[:base] << "You can't recommend items to yourself!"
      end
    end
  end

  validates_with RecursionValidator

  before_validation :set_pending_status

  def self.create_by_id_and_email(recommender, params)
    recommendee_ids = params["recommendee_ids"]
    recommendee_emails = params["recommendee_emails"]
    item_class = Kernel.const_get(params['item_type'])
    item = item_class.find(params['item_id'])

    new_recommendations = []

    unless recommendee_ids.nil?
      recommendee_ids.each do |id|
        recommendee = User.find(id)
        reco = Recommendation.new(
          :recommender => recommender,
          :recommendee => recommendee,
          :item => item
        )
        if reco.save
          new_recommendations.append(reco)
        else
          #Handle batch error
        end
      end
    end

    unless recommendee_emails.nil?
      recommendee_emails.each do |email|
        recommendee = User.find_by_email(email)
        if recommendee
          reco = Recommendation.new(
            :recommender => recommender,
            :recommendee => recommendee,
            :item => item
          )
          if reco.save
            new_recommendations.append(reco)
          else
            #Handle batch error
          end
        else
          #TODO - New user. Send email with new recommendation.
        end
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

end
