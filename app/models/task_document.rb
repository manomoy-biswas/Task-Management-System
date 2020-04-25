class TaskDocument < ApplicationRecord
  belongs_to :task
  
  mount_uploader :document, DocumentUploader
end
