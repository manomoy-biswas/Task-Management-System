require 'elasticsearch/model'
class User < ApplicationRecord
  include ApplicationHelper
  include Elasticsearch::Model

  has_secure_password(validations: false) 

  has_many :tasks, foreign_key: "assign_task_to", dependent: :destroy
  has_many :notifications, foreign_key: "user_id"
  
  mount_uploader :avater, AvaterUploader

  attr_accessor :role
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
                      #/\A([a-zA-Z0-9]+)([.{1}])?([a-zA-Z0-9]+)@g(oogle)?mail([.])com\z/.freeze
  VALID_PHONE_REGEX=/\A[6-9][0-9]{9}\z/.freeze

  before_validation :valid_name
  before_validation :valid_email

  after_create :welcome_user_email
  after_commit  :index_user,  on: [:create, :update]
  after_commit  :delete_user_index, on: :destroy

  validates :name, length: { in: 3..50 }
  validates :email, format: { with: VALID_EMAIL_REGEX }
  validates :phone, length: {is: 10}, format: { with: VALID_PHONE_REGEX }
  validate :valid_dob?
  validates :password, length: { minimum: 5 }, allow_nil: true
  validates_presence_of :name, :email, :phone
  validates_uniqueness_of :email, :phone, case_sensitive: true

  scope :all_users_except_admin, -> { where(admin: false)}
  scope :all_hr, -> { where(hr: true) }
  scope :all_admin, -> { where(admin: true) }
  scope :all_employee, -> {where(admin: false, hr: false)}
  scope :all_user_except, -> (user_id) {where.not(id: user_id)}
  scope :all_user_except_admin_and, -> (user_id) {where.not(id: user_id, admin:true)}

  mappings dynamic: "false" do
    indexes :id, type: :text 
    indexes :name, type: "text"
    indexes :email, type: "text"
    indexes :phone, type: "text"
  end
  
  def as_indexed_json(options = {})
    self.as_json(
      options.merge(only: [:id, :name, :email, :phone])
    )
  end

  def self.search(query)
    __elasticsearch__.search(query:{
      "query_string": {
        "query": "*#{query}*",
        "fields": ["name", "email", "phone"]
      }
    })
  end

  def self.from_omniauth(auth)
    data = auth.info
    user = User.where(email: data["email"]).first
    user
  end
  
  def self.all_except(user_id)
    where.not(id: user_id)
  end

  def self.fetch_user(filter = nil, query = nil, current_user)
    if query.present?
      user_ids = self.search(query).map(&:id)
      return self.where(id: user_ids).order("name ASC")
    else
      if filter  == "" || !filter 
        if current_user.admin
          self.all.order("name ASC")
        elsif current_user.hr
          self.all_users_except_admin.order("name ASC") 
        end
      elsif filter  == "Admin"
        self.all_admin.order("name ASC") unless current_user.hr
      elsif filter  == "HR"
        self.all_hr.order("name ASC")
      else
        self.all_employee.order("name ASC")
      end
    end
  end  

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    ResetPasswordWorker.perform_async(self.id)
  end
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def self.generate_auth_token(column, user)
    user[column] = SecureRandom.urlsafe_base64
    user.save!
  end
  def display_name
    names = self.name.split(" ")
    if names.first[-1] == "."
      name = names.first + " " + names[1]
    else
      name = names.first
    end
    name
  end

  private

  def valid_dob?
    if dob.present?
      errors.add(:dob, :invalid, message: "#{dob} is invalid. DOB should be before #{18.years.ago.to_date}") if dob > 18.years.ago.to_date
    else
      errors.add(:dob, :blank, message: "DOB can't be blank")
    end 
  end

  def valid_name
    self.name = name.to_s.titleize.strip
  end

  def valid_email
    self.email = email.to_s.downcase.strip
  end

  def index_user
    UserIndexerWorker.perform_async("index",  self.id)
  end

  def delete_user_index
    UserIndexerWorker.perform_async("delete", self.id)
  end

  def welcome_user_email
    UserMailerWorker.perform_async(self.id)
  end
end
