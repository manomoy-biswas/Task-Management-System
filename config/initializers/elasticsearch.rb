if Rails.env.production?
  Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['BONSAI_URL']
elsif Rails.env.development?
  Elasticsearch::Model.client = Elasticsearch::Client.new url: "http://elasticsearch:9200"
end