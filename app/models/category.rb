class Category < ApplicationRecord
  before_validation { self.name = name.to_s.titleize.strip }

  validates :name, presence: true, length: { in: 2..30 }
  validates_uniqueness_of :name, case_sensitive: false

  has_many :tasks
  
end
