class User < ApplicationRecord
  has_secure_password(validations: false) 
  has_many :tasks, foreign_key: "assign_task_to", primary_key: "id", dependent: :destroy


  VALID_EMAIL_REGEX = /\A([a-zA-Z0-9]+)([\.{1}])?([a-zA-Z0-9]+)\@g(oogle)?mail([\.])com\z/.freeze
  VALID_PHONE_REGEX=/\A[6-9]{1}[0-9]{9}\z/.freeze

  attr_accessor :roles
  before_validation { self.name = name.to_s.titleize.strip }
  before_validation { self.email = email.to_s.downcase.strip }

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :phone, presence: true, length: {is: 10}, format: { with: VALID_PHONE_REGEX }, uniqueness: true
  validates :dob, presence: true
  validate :valid_dob
  validates :password, presence: true, length: { minimum: 5 }, allow_nil: true

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def user_name
    return self.name
  end

  def self.from_omniauth(auth)
    data = auth.info
    user = User.where(email: data["email"]).first

    unless user
      user = User.new(
        email: data["email"],
        provider: auth.provider,
        uid: auth.uid
        )
    end
    user
  end
  
  def self.all_except(user)
    where.not(id: user)
  end

  private
  def valid_dob
    if dob >= Date.today
      errors.add(:dob, "is invalid")
    elsif dob > 18.years.ago.to_date
      errors.add("DOB should be before ", 18.years.ago.to_date)
    end
  end
end
