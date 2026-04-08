class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[mark_read]

  # GET /notifications
  def index
    authorize Notification
    notifications = policy_scope(Notification).recent_first.limit(50)
    render json: NotificationSerializer.new(notifications).serializable_hash
  end

  # PATCH /notifications/:id/mark_read
  def mark_read
    authorize @notification, :mark_read?
    @notification.mark_read!
    render json: NotificationSerializer.new(@notification).serializable_hash
  end

  # POST /notifications/mark_all_read
  def mark_all_read
    authorize Notification, :index?
    policy_scope(Notification).unread.update_all(read_at: Time.current)
    head :no_content
  end

  private

  def set_notification
    @notification = Notification.find(params[:id])
  end
end
