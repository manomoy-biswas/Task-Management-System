class User < ApplicationRecord
  has_secure_password(validations: false)

  VALID_EMAIL_REGEX = /\A([a-zA-Z0-9]+)([\.{1}])?([a-zA-Z0-9]+)\@g(oogle)?mail([\.])com\z/.freeze
  VALID_PHONE_REGEX=/\A[6-9]{1}[0-9]{9}\z/.freeze

  attr_accessor :roles
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :phone, presence: true, length: {is: 10}, format: { with: VALID_PHONE_REGEX },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 5 }, allow_nil: true

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
end
