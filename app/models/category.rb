class Category < ApplicationRecord
  before_vcalidation { self.mane = name.to_s.downcase.strip }
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
end
