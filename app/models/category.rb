class Category < ApplicationRecord
  before_validation { self.name = name.to_s.titleize.strip }
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  has_many :tasks
end
