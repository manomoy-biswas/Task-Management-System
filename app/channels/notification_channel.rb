class NotificationChannel < ApplicationCable::Channel
  def subscribed
    if current_user
      stream_from "notification#{current_user.id}"
    else
      reject
    end
  end 
  def unsubscribed
    stop_all_streams
  end
end
