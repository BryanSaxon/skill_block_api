class NotificationPolicy < ApplicationPolicy
  # Users can only see and modify their own notifications.

  def index?
    true
  end

  def show?
    record.user_id == user.id
  end

  def mark_read?
    record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
