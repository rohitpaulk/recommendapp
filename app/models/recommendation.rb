class Recommendation < ActiveRecord::Base
	belongs_to :recommendee, :class_name => "User"
	belongs_to :recommender, :class_name => "User"
	belongs_to :item, :polymorphic => true

  validates_presence_of :recommendee
  validates_presence_of :recommender
  validates_presence_of :item
  validates_presence_of :status

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

  def set_pending_status
    self.status ||= 'pending'
  end

  def send_notification
    recommendee.send_notification(self.attributes)
  end
end
