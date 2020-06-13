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
  after_create :task_create_email
  after_create :task_create_notification

  validates :task_name, length: { maximum: 255 }
  validates :task_name, :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validates :priority, inclusion: %w[High Medium Low]
  validates :repeat, inclusion: %w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]
  # validate :valid_submit_date, on: :create
  # validate :valid_updated_submit_date, on: :update
  validates_uniqueness_of :task_name, case_sensitive: false


  scope :my_assigned_tasks, ->(user_id=nil) { where(assign_task_by: user_id) }
  scope :my_assigned_tasks_filter, ->(param=nil,user_id=nil) { where(priority: param, assign_task_by: user_id) }
  scope :approved_tasks, ->{ where(approved: true) }
  scope :approved_tasks_filter, ->(param=nil) { where(priority: param, approved: true) }
  scope :notified_tasks, ->{ where(approved: true, notify_hr: true) }
  scope :notified_tasks_filter, ->(param=nil) { where(priority: param, approved: true, notify_hr: true) }
  scope :admin_task_filter, ->(param=nil) { where(priority: param ) }
  scope :my_task_filter, ->(param=nil, user_id) { where(priority: param , assign_task_to: user_id ) }
  scope :recurring_task, -> { where(recurring_task: true) }

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

  def self.task_search(param, current_user)
    if current_user.admin
      self.all_task_search(param.present? ? param : nil)
    else
      self.search((param.present? ? param : nil), current_user.id)
    end  
  end

  def self.filter_by_priority(param, current_user)
    if current_user.admin
      if !param || param == ""
        self.includes(:user, :assign_by, :category).order("created_at DESC")
      else
        self.admin_task_filter(param).includes(:user, :assign_by, :category).order("created_at DESC")
      end    
    else
      if !param || param == ""
        current_user.tasks.includes(:assign_by, :category).order("created_at DESC")
      else
        self.my_task_filter(param, current_user.id).includes(:assign_by, :category).order("created_at DESC")
      end
    end
  end

  def self.filter_approved_task_by_priority(param, current_user)
    if current_user.admin
      if !param || param == ""
        self.approved_tasks.includes(:user, :assign_by, :category).order("created_at DESC")
      else
        self.approved_tasks_filter(param).includes(:user, :assign_by, :category).order("created_at DESC")
      end    
    elsif current_user.hr
      if !param || param == ""
        self.notified_tasks.includes(:user, :category).order("created_at DESC")
      else
        self.notified_tasks_filter(param).includes(:user, :category).order("created_at DESC")
      end
    end
  end

  def self.filter_user_assigned_task_by_priority(param, current_user)
    if !param || param == ""
      self.my_assigned_tasks(current_user.id).includes(:user, :category).order("created_at DESC")
    else
      self.my_assigned_tasks_filter(param,current_user.id).includes(:user, :category).order("created_at DESC")
    end  
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
  
  def task_create_email
    TaskMailerWorker.perform_async(self.id,"create")
  end

  def task_create_notification
    Notification.create_notification(self.id, "assigned")
  end
end