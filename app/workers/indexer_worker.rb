class IndexerWorker
  include Sidekiq::Worker
  sidekiq_options retry: true
  
  def perform(*args)
    Task.__elasticsearch__.client.indices.delete index: Task.index_name rescue nil

    Task.__elasticsearch__.client.indices.create \
      index: Task.index_name,
      body: { settings: Task.settings.to_hash, mappings: Task.mappings.to_hash }

    Task.import
  end
end
