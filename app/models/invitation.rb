class Invitation < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  before_validation :valid_name
  before_validation :valid_email

  validates :name, length: { in: 3..50 }
  validates :email, length: { in: 7..50 }, format: { with: VALID_EMAIL_REGEX }
  validates_presence_of :name, :email
  validates_uniqueness_of :email, case_sensitive: true
  
  after_create_commit :send_invitation
  
  def self.generate_token
    SecureRandom.urlsafe_base64
  end

  private

  def send_invitation
    InvitationWorker.perform_async(self.id)
  end

  def valid_name
    self.name = name.to_s.titleize.strip
  end

  def valid_email
    self.email = email.to_s.downcase.strip
  end
end
