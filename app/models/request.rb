class Request < ActiveRecord::Base
  belongs_to :requestee, :class_name => "User"
  belongs_to :requester, :class_name => "User"

  validates_presence_of :requestee
  validates_presence_of :requester
  validates_presence_of :item_type
  validates_inclusion_of :item_type, in: ["Movie", "App"]
  validates_presence_of :status
  validates_inclusion_of :status, in: ["pending", "sent", "seen", "successful"]

  validates_uniqueness_of :item_type, scope: [:requestee, :requester], 
  conditions: -> { where( status: ["pending","sent"] ) }

  class RequestValidator < ActiveModel::Validator
    def validate(record)
      if record.requester_id == record.requestee_id
        record.errors[:base] << "You can't request items to yourself!"
      end
    end
  end

  validates_with RequestValidator

  before_validation :set_pending_status

  def set_pending_status
    self.status ||= 'pending'
  end

  def send_notification
    requestee.send_notification(self.serializable_hash(:include => ["requester", "requestee"]))
    self.status = 'sent'
    save!
  end

end
