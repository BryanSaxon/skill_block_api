class NotificationSerializer
  include JSONAPI::Serializer

  attributes :notification_type, :message, :navigation_target, :read_at, :created_at

  belongs_to :user
end
