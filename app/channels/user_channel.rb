# UserChannel — per-user notification stream.
#
# Flutter subscribes with: { "channel": "UserChannel" }
# (No params needed — the user is identified by the connection.)
# Broadcasts:
#   notification     — a new notification was created for this user
#   notification_read — a notification was marked as read
class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_#{current_user.id}"
  end

  def unsubscribed
  end

  # Call after Notification.create! to push to the user's devices.
  def self.broadcast_notification(notification)
    ActionCable.server.broadcast("user_#{notification.user_id}", {
      type: "notification",
      notification: {
        id: notification.id,
        notification_type: notification.notification_type,
        message: notification.message,
        navigation_target: notification.navigation_target,
        created_at: notification.created_at.iso8601
      },
      broadcast_at: Time.current.iso8601
    })
  end

  def self.broadcast_read(notification)
    ActionCable.server.broadcast("user_#{notification.user_id}", {
      type: "notification_read",
      notification_id: notification.id,
      broadcast_at: Time.current.iso8601
    })
  end
end
