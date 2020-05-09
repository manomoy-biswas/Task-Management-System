# frozen_string_literal: true
require 'elasticsearch/model'
class Task < ApplicationRecord
  include SessionsHelper
  include Elasticsearch::Model

  belongs_to :user, foreign_key: "assign_task_to", required: true
  belongs_to :assign_by, class_name: "User", foreign_key: "assign_task_by"
  belongs_to :category, foreign_key: 'task_category', required: true
  has_many :notification, foreign_key: 'notifiable_id', dependent: :destroy
  has_many :sub_task, dependent: :destroy
  has_many :task_document, dependent: :destroy
  
  before_validation { self.task_name = task_name.to_s.squeeze(" ").strip.capitalize }

  accepts_nested_attributes_for :sub_task, reject_if: ->(a) { a[:name].blank? }, allow_destroy: true
  
  after_commit  :index_task,  on: [:create, :update]
  after_commit  :delete_task_index, on: :destroy

  after_create :task_reminder_email
  after_create { TaskMailerWorker.perform_async(self.id,"create") }

  validates :task_name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validates :priority, inclusion: %w[High Medium Low]
  validates :repeat, inclusion: %w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]
  validate :valid_submit_date, on: :create
  validate :valid_updated_submit_date, on: :update


  scope :my_assigned_tasks, ->(user_id=nil) { where(assign_task_by: user_id) }
  scope :my_assigned_tasks_filter, ->(param=nil,user_id=nil) { where(priority: param, assign_task_by: user_id) }
  scope :approved_tasks, ->{ where(approved: 1) }
  scope :approved_tasks_filter, ->(param=nil) { where(priority: param, approved: 1) }
  scope :notified_tasks, ->{ where(approved: 1, notify_hr: 1) }
  scope :notified_tasks_filter, ->(param=nil) { where(priority: param, approved: 1, notify_hr: 1) }
  scope :admin_task_filter, ->(param=nil) { where(priority: param ) }
  scope :my_task_filter, ->(param=nil, user_id) { where(priority: param , assign_task_to: user_id ) }
  scope :recurring_task, -> { where(repeat: true) }

  mappings dynamic: "false" do
    indexes :id, type: :text 
    indexes :task_name, type: "text"
    indexes :assign_task_to, type: "text"
    indexes :search_field
    indexes :category do
      indexes :name, type: "text", copy_to: :search_field
    end
    indexes :sub_task, type: "nested" do
      indexes :name, type: "text", copy_to: :search_field
    end
    indexes :user do
      indexes :name, type: "text", copy_to: :search_field
    end
  end
  
  def as_indexed_json(options = {})
    self.as_json(
      options.merge(only: [:id, :task_name, :assign_task_to],
        include: {
          category: {only: :name},
          sub_task: {only: :name},
          user: {only: :name}
        }
      )
    )
  end

  def self.all_task_search(query)
    __elasticsearch__.search(query:{
      bool: {  
        must: {
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "search_field"],
            operator: "and"
          }
        },
      }
    })
  end

  def self.search(query, current_user_id)
    __elasticsearch__.search(query: multi_match_query(query,current_user_id))
  end

  def self.multi_match_query(query, current_user_id)
    { 
      bool: {  
        must: {
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "search_field"],
            operator: "and"
          }
        },
        filter: {
          term: {
            "assign_task_to": current_user_id.to_s
          }
        }
      }
    }
  end
  
  private
  
  def valid_submit_date
    return unless submit_date <= DateTime.now + 1.day
    errors.add(:submit_date, " can not be assign to a previous date/time")
  end
  
  def valid_updated_submit_date
    return unless submit_date <= created_at.to_datetime + 1.day
    errors.add(:submit_date, " must be greated that created date")
  end
  
  def index_task
    IndexerWorker.perform_async("index",  self.id)
  end

  def delete_task_index
    IndexerWorker.perform_async("delete", self.id)
  end

  def task_reminder_email
    return if DateTime.now + 7.days > self.submit_date.to_datetime
    TaskReminderWorker.perform_at(self.submit_date.to_datetime - 7.days, self.id)
  end
end