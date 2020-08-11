module NotificationsHelper
  def unread_notification
      Notification.unread(current_user.id).reverse
  end
end