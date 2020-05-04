class IndexerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(action, task_id)
    if action == "index"
      record = Task.find(task_id) 
      record.__elasticsearch__.index_document\
    elsif action == "delete"
      client = Task.__elasticsearch__.client
      client.delete index: Task.index_name, type: "_doc", id: task_id
    end
  end

end
