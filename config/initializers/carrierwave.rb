# CarrierWave.configure do |config|
#   # if Rails.env.production?
#   config.fog_credentials = {
#     provider:              "AWS",                                       # required
#     aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],   # required
#     aws_secret_access_key: ENV['AWS_SECRET_KEY_ID'],  # required
#     region:                "us-east-1"                                  # optional, defaults to "us-east-1"
#   }
#   config.fog_directory  =  ENV['AWS_BUCKET']                             # required
#   #config.fog_host      =  "https://assets.example.com"                 # optional, defaults to nil
#   config.fog_public     =  false                                        # optional, defaults to true
#   config.fog_attributes =  {"Cache-Control": "max-age=315576000"}       # optional, defaults to {}
#   # end
# end
CarrierWave.configure do |config|
  if Rails.env.production?
    config.aws_bucket = ENV['AWS_BUCKET']
    config.aws_acl    = :private
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
    config.aws_attributes = -> { {
      expires: 1.week.from_now.httpdate,
      cache_control: 'max-age=604800'
    } }
    config.aws_credentials = {
      access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_KEY_ID'],
      region:            "us-east-1"
    }
  end
end

