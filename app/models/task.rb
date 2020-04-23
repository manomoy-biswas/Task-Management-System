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
  
  # after_destroy :destroy_notifications
  after_create :task_reminder_email

  after_create { TaskMailerWorker.perform_async(self.id,"create") }
  after_update { TaskMailerWorker.perform_async(self.id,"update") }

  VALID_TASK_NAME_REGEX = /\A[a-zA-Z][a-zA-Z\. ]*\z/.freeze

  validates :task_name, presence: true, length: { maximum: 255 }, format: { with: VALID_TASK_NAME_REGEX }, uniqueness: true
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validates :priority, inclusion: %w[High Medium Low]
  validates :repeat, inclusion: %w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]
  validate :valid_submit_date, on: :create
  # has_attached_file :document
  # validates_attachment :document, content_type: { content_type: %w[image/jpeg image/jpg image/png application/pdf] }
  # mount_uploader :document, DocumentUploader

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

  def self.search(query, current_user_id)
    __elasticsearch__.search(query: multi_match_query(query,current_user_id))
  end

  def self.search(query)
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

    errors.add(:submit_date, ' can not be assign to a previous date')
  end

  def find_user_name(user_id)
    User.find(id: user_id).name
  end

  private


  def task_reminder_email
    return if DateTime.now.utc + 7.days > self.submit_date.to_datetime
    TaskReminderWorker.perform_at(self.submit_date.to_datetime - 7.days, self.id)
  end
end

# Delete the previous articles index in Elasticsearch
Task.__elasticsearch__.client.indices.delete index: Task.index_name rescue nil

# Create the new index with the new mapping
Task.__elasticsearch__.client.indices.create \
  index: Task.index_name,
  body: { settings: Task.settings.to_hash, mappings: Task.mappings.to_hash }

# Index all article records from the DB to Elasticsearch
Task.import