class Request < ActiveRecord::Base
  belongs_to :requestee, :class_name => "User"
  belongs_to :requester, :class_name => "User"
  belongs_to :response, :class_name => "Recommendation"

  validates_presence_of :requestee
  validates_presence_of :requester
  validates_presence_of :item_type
  validates_inclusion_of :item_type, in: ["Movie", "AndroidApp"]
  validates_presence_of :status
  validates_inclusion_of :status, in: ["pending", "sent", "seen", "successful"]

  validates_uniqueness_of :item_type, scope: [:requestee, :requester],
    conditions: -> { where( status: ["pending","sent"] ) }

  after_create :send_notification

  class RequestValidator < ActiveModel::Validator
    def validate(record)
      if record.requester_id == record.requestee_id
        record.errors[:base] << "You can't request items to yourself!"
      end
    end
  end

  validates_with RequestValidator

  before_validation :set_pending_status

  def self.create_by_id_and_email(requester, item_type, requestee_ids, requestee_emails)
    new_requests = []

    requestee_ids.each do |id|
      requestee = User.find_by_id(id)
      if requestee
        new_requests.append(create_request(requester, requestee, item_type))
      else
        new_requests.append(format_error["Invalid requestee id!"])
      end
    end

    requestee_emails.each do |email|
      requestee = User.find_by_email(email)
      if requestee
        new_requests.append(create_request(requester, requestee, item_type))
        #TODO make them friends
      else
        #TODO New user, send email!
      end
    end
    new_requests
  end

  def set_pending_status
    self.status ||= 'pending'
  end

  def send_notification
    notification = Notification.new("Request", requester.name, item_type)
    requestee.send_notification(notification.instance_values)
    self.status = 'sent'
    save!
  end

  private
  def self.create_request(requester, requestee, item_type)
    request = Request.new(
      :requester => requester,
      :requestee => requestee,
      :item_type => item_type
    )
    unless request.save
      return format_error(request.errors.full_messages)
    end
    return request
  end

  def self.format_error(msg)
    return { :errors => msg }
  end
end