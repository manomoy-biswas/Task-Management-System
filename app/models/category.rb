class Category < ApplicationRecord
  before_validation :valid_name
  
  validates :name, length: { in: 2..30 }
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  has_many :tasks, foreign_key: "task_category"
  
  private
  def valid_name
    self.name = name.to_s.titleize.strip
  end
end
