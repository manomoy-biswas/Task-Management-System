module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    def connect
      self.current_user = User.find_by_auth_token!(cookies[:auth_token])
      # logger.add_tags 'ActionCable', current_user.id
    end
    def session
      cookies.encrypted[Rails.application.config.session_options[:key]]
    end
  end
end
