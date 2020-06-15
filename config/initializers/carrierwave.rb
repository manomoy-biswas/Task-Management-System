CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              "AWS",                                       # required
    aws_access_key_id: "AKIAZPOH63D5IIPWOCOR",   # required
    aws_secret_access_key: "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",  # required
    region:                "us-east-1"                                  # optional, defaults to "us-east-1"
  }
  config.fog_directory  =  "tms-kreeti"                               # required
  #config.fog_host      =  "https://assets.example.com"                 # optional, defaults to nil
  config.fog_public     =  false                                        # optional, defaults to true
  config.fog_attributes =  {"Cache-Control": "max-age=315576000"}       # optional, defaults to {}
end

