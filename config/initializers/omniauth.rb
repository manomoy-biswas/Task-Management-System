OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '1045289260619-a1td6k3rd6ua9d7m0sru5iic70ao828t.apps.googleusercontent.com', 'OngxONH0-RPoROStwJgfo-Rt'
end