# frozen_string_literal: true
require 'elasticsearch/model'
require "zip"
class Task < ApplicationRecord
  include SessionsHelper
  include Elasticsearch::Model

  belongs_to :user, foreign_key: "assign_task_to", required: true
  belongs_to :assign_by, class_name: "User", foreign_key: "assign_task_by"
  belongs_to :category, foreign_key: 'task_category', required: true
  has_many :notification, foreign_key: 'notifiable_id', dependent: :destroy
  has_many :sub_task, dependent: :destroy
  has_many :task_document, dependent: :destroy
  
  before_validation :squeeze_task_name

  accepts_nested_attributes_for :sub_task, reject_if: ->(a) { a[:name].blank? }, allow_destroy: true
  
  after_commit  :index_task,  on: [:create, :update]
  after_commit  :delete_task_index, on: :destroy

  after_create :task_reminder_email
  after_create :task_create_email
  after_create :task_create_notification

  validates :task_name, length: { maximum: 255 }
  validates :priority, inclusion: %w[High Medium Low]
  validates :repeat, inclusion: %w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]
  validate :valid_submit_date, on: :create
  validate :valid_updated_submit_date, on: :update
  validates_uniqueness_of :task_name, case_sensitive: false
  validates_presence_of :task_name, :priority, :repeat, :assign_task_to, :task_category

  scope :my_assigned_tasks, ->(user_id=nil) { where(assign_task_by: user_id).includes(:user, :category) }
  scope :my_assigned_tasks_filter, ->(param=nil,user_id=nil) { where(priority: param, assign_task_by: user_id).includes(:user, :category) }
  scope :approved_tasks, ->{ where(approved: true).includes(:user, :assign_by, :category) }
  scope :approved_tasks_filter, ->(param=nil) { where(priority: param, approved: true).includes(:user, :assign_by, :category) }
  scope :users_approved_tasks, ->(user_id) { where(approved: true, assign_task_to: user_id).includes(:assign_by, :category)}
  scope :users_approved_tasks_filter, ->(param, user_id) { where(priority: param, approved: true, assign_task_to: user_id).includes(:assign_by, :category)}

  scope :notified_tasks, ->{ where(approved: true, notify_hr: true).includes(:user, :assign_by, :category) }
  scope :notified_tasks_filter, ->(param=nil) { where(priority: param, approved: true, notify_hr: true).includes(:user, :assign_by, :category) }
  scope :admin_task_filter, ->(param=nil) { where(priority: param, approved: false).includes(:user, :assign_by, :category) }
  scope :my_task_filter, ->(param=nil, user_id) { where(priority: param , approved: false, assign_task_to: user_id ).includes(:assign_by, :category) }
  scope :recurring_task, -> { where(recurring_task: true).includes(:user, :assign_by, :category) }

  mappings dynamic: "false" do
    indexes :id, type: :text 
    indexes :task_name, type: :text
    indexes :description, type: :text
    indexes :assign_task_to, type: :text
    indexes :assign_task_by, type: :text
    indexes :approved, type: :boolean
    indexes :notify_hr, type: :boolean
    indexes :search_field
    indexes :category do
      indexes :name, type: "text", copy_to: :search_field
    end
    indexes :sub_task, type: "nested" do
      indexes :name, type: "text", copy_to: :search_field
      indexes :subtask_description, type: "text", copy_to: :search_field
    end
  end
  
  def as_indexed_json(options = {})
    self.as_json(
      options.merge(only: [:id, :task_name, :description, :assign_task_by, :assign_task_to, :approved, :notify_hr],
        include: {
          category: {only: :name},
          sub_task: {only: [:name, :subtask_description]}
        }
      )
    )
  end

  def self.all_task_search(query)
    __elasticsearch__.search(query:{
      bool: {  
        must: [{
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "description","assign_task_by", "search_field"],
            operator: "and"
          }
        },
        {
          match: {
            approved: false
          }
        }],
      }
    })
  end

  def self.search(query, current_user_id)
    __elasticsearch__.search(query: 
    { 
      bool: {  
        must: [{
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "description", "search_field"],
            operator: "and"
          }
        },
        {
          match: {
            approved: false
          }
        }],
        filter: {
          term: {
            "assign_task_to": current_user_id.to_s
          }
        }
      }
    })
  end

  def self.users_approved_tasks_search(query, current_user_id)
    __elasticsearch__.search(query:{ 
      bool: {  
        must: [{
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "description", "search_field"],
            operator: "and"
          }
        },
        {
          match: {
            approved: true
          }
        }],
        filter: {
          term: {
            "assign_task_to": current_user_id.to_s
          }
        }
      }
    })
  end

  def self.approved_tasks_search(query)
    __elasticsearch__.search(query:{ 
      bool: {  
        must: [{
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "description", "search_field"]
          }
        },
        {
          match: {
            approved: true
          }
        }]
      }
    })
  end

  def self.user_assigned_tasks_search(query, current_user_id)
    __elasticsearch__.search(query:{ 
      bool: {  
        must: {
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "description", "search_field"],
            operator: "and"
          }
        },
        filter: {
          term: {
            "assign_task_by": current_user_id.to_s
          }
        }
      }
    })
  end

  def self.notified_tasks_search(query)
    __elasticsearch__.search(query:{ 
      bool: {  
        must: [{
          multi_match: {
            query: query,
            type: "best_fields",
            fields: ["task_name", "description", "search_field"]
          }
        },
        {
          match: {
            notify_hr: true
          }
        }]
      }
    })
  end

  def self.fetch_tasks(filter = nil, query = nil, current_user)
    if query.present?
      if current_user.admin
        tasks = self.all_task_search(query).map(&:id)
      else
        tasks = self.search(query, current_user.id).map(&:id)
      end
      return self.where(id: tasks).includes(:user, :category, :assign_by).order("id DESC")
    elsif filter.present?
      if current_user.admin
        self.admin_task_filter(param).order("created_at DESC")
      else
        self.my_task_filter(param, current_user.id).order("created_at DESC")
      end    
    else
      if current_user.admin
        self.where(approved: false).includes(:user, :assign_by, :category).order("created_at DESC")
      else
        current_user.tasks.where(approved: false).includes(:assign_by, :category).order("created_at DESC")
      end
    end
  end

  def self.fetch_approved_tasks(filter = nil, query = nil, current_user)
    if query.present?
      if current_user.admin
        tasks = self.approved_tasks_search(query).map(&:id)
      else
        tasks = self.users_approved_tasks_search(query, current_user.id).map(&:id)
      end
     self.where(id: tasks).includes(:user, :category, :assign_by).order("id DESC")
    elsif filter.present?
      if current_user.admin
        self.approved_tasks_filter(filter).order("created_at DESC")
      elsif current_user.hr
        self.notified_tasks_filter(filter).order("created_at DESC")
      else
        self.users_approved_tasks_filter(filter, current_user.id).order("created_at DESC")
      end
    else
      if current_user.admin
        self.approved_tasks.order("created_at DESC")
      elsif current_user.hr
        self.notified_tasks.order("created_at DESC")
      else
        self.users_approved_tasks(current_user.id).order("created_at DESC")
      end
    end
  end

  def self.fetch_user_assigned_tasks(filter = nil, query = nil, current_user)
    if query.present?
      tasks = self.user_assigned_tasks_search(query, current_user.id).map(&:id)
      self.where(id: tasks).includes(:user, :category, :assign_by).order("id DESC")
    elsif filter.present?
      self.my_assigned_tasks_filter(filter, current_user.id).order("created_at DESC")
    else
      self.my_assigned_tasks(current_user.id).order("created_at DESC")
    end  
  end

  def self.fetch_notified_tasks(filter = nil, query = nil)
    if query.present?
      tasks = self.notified_tasks_search(query).map(&:id)
      self.where(id: tasks).includes(:user, :category, :assign_by).order("updated_at DESC")
    elsif filter.present?
      self.notified_tasks_filter(filter).order("created_at DESC")
    else
      self.notified_tasks.order("created_at DESC")
    end  
  end

  def self.send_notified_email(task_id)
    User.where(hr: true).each do |user|
      TaskMailerWorker.perform_async(task_id, "notified", user.id)
    end
  end

  private

  def squeeze_task_name
    self.task_name = task_name.to_s.squeeze(" ").strip.capitalize
  end

  def valid_submit_date
    if submit_date.present?
      errors.add(:submit_date, :invalid, message:"Submit date can't be assign to a previous date/time.") unless submit_date >= DateTime.now + 1.day
    else
      errors.add(:submit_date, :blank, message: "Submit date can't be blank")
    end
  end

  def valid_updated_submit_date
    if submit_date.present?
      errors.add(:submit_date, :invalid, message:"Submit date must be greated that created date") unless submit_date >= created_at.to_datetime + 1.day
    else
      errors.add(:submit_date, :blank, message: "Submit date can't be blank")
    end
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