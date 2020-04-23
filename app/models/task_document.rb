class TaskDocument < ApplicationRecord
  mount_uploader :document, DocumentUploader
  belongs_to :task

  # validates :document, file_size: { less_than: 50.megabytes }
  # validates :document, file_size: { maximum: 50.megabytes.to_i, remove_if_invalid: true }

end
