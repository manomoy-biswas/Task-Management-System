class UserIndexerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(action, user_id)
    if action == "index"
      record = User.find(user_id) 
      record.__elasticsearch__.index_document
    elsif action == "delete"
      client = User.__elasticsearch__.client
      client.delete index: User.index_name, type: "_doc", id: user_id
    end
  end
end
