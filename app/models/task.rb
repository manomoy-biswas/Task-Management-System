# frozen_string_literal: true
require 'elasticsearch/model'
class Task < ApplicationRecord
  include SessionsHelper
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :user, foreign_key: 'assign_task_to', required: true
  belongs_to :category, foreign_key: 'task_category', required: true
  has_many :notification, foreign_key: 'notifiable_id', dependent: :destroy
  has_many :sub_task, dependent: :destroy
  has_many :task_document, dependent: :destroy
  
  before_validation { self.task_name = task_name.to_s.squeeze(" ").strip.capitalize }

  accepts_nested_attributes_for :sub_task, reject_if: ->(a) { a[:name].blank? }, allow_destroy: true
  
  after_commit :index_document
  after_create :task_reminder_email
  after_create { TaskMailerWorker.perform_async(self.id,"create") }
  after_update { TaskMailerWorker.perform_async(self.id,"update") }

  VALID_TASK_NAME_REGEX = /\A[a-zA-Z][a-zA-Z\. ]*\z/.freeze

  validates :task_name, presence: true, length: { maximum: 255 }, format: { with: VALID_TASK_NAME_REGEX }, uniqueness: true
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validates :priority, inclusion: %w[High Medium Low]
  validates :repeat, inclusion: %w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]
  validate :valid_submit_date, on: :create

  scope :my_assigned_tasks, ->(user_id=nil) { where(assign_task_by: user_id) }
  scope :my_assigned_tasks_filter, ->(param=nil,user_id=nil) { where(priority: param, assign_task_by: user_id) }
  scope :approved_tasks, ->{ where(approved: 1) }
  scope :approved_tasks_filter, ->(param=nil) { where(priority: param, approved: 1) }
  scope :notified_tasks, ->{ where(approved: 1, notify_hr: 1) }
  scope :notified_tasks_filter, ->(param=nil) { where(priority: param, approved: 1, notify_hr: 1) }
  scope :admin_task_filter, ->(param=nil) { where(priotity: param ) }
  scope :my_task_filter, ->(param=nil, user_id) { where(priority: param , assign_task_to: user_id ) }
  scope :recurring_task, -> { where(repeat: true) } 


  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :id, type: :text 
      indexes :task_name, type: "text"
      indexes :description, type: "text"
      indexes :priority, type: "text"
      indexes :assign_task_to, type: "text"
      indexes :assign_task_by, type: "text"
      indexes :search_field
      
      indexes :category do
        indexes :id, type: :long
        indexes :name, type: "text", copy_to: :search_field
      end
      indexes :sub_task, type: "nested" do
        indexes :id, type: :long
        indexes :name, type: "text", copy_to: :search_field
        indexes :subtask_description, type: "text", copy_to: :search_field
      end
    end
  end
  
  def as_indexed_json(options = {})
    self.as_json(
      options.merge(only: [:id,:task_name, :description, :assign_task_to],
        include: {
          category: {only: [:id, :name]},
          sub_task: {only: [:id, :name, :subtask_description]},
          user: {only: [:id, :name]}
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
            fields: ["id", "task_name","priority", "description", "search_field"],
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
            fields: ["id", "task_name","priority", "description", "search_field"],
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

  def valid_submit_date
    return unless submit_date.to_datetime <= DateTime.now + 1.day

    errors.add(:submit_date, " can not be assign to a previous date")
  end

  private

  def index_document
    IndexerWorker.perform_async
  end

  def task_reminder_email
    return if DateTime.now + 7.days > self.submit_date.to_datetime
    TaskReminderWorker.perform_at(self.submit_date.to_datetime - 7.days, self.id)
  end
end