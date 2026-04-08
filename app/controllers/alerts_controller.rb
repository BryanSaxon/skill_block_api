class AlertsController < ApplicationController
  before_action :set_machine
  before_action :set_alert, only: %i[show acknowledge]

  # GET /organizations/:organization_id/organization_machines/:organization_machine_id/alerts
  # Query params:
  #   status — "active" | "acknowledged" | "resolved" | "open" (active+acknowledged)
  def index
    authorize Alert

    alerts = policy_scope(Alert).where(organization_machine: @machine)

    alerts = case params[:status]
    when "active" then alerts.where(status: :active)
    when "acknowledged" then alerts.where(status: :acknowledged)
    when "resolved" then alerts.where(status: :resolved)
    when "open" then alerts.open
    else alerts.open   # default to open
    end

    alerts = alerts.severity_first

    render json: AlertSerializer.new(alerts).serializable_hash
  end

  # GET /organizations/:organization_id/organization_machines/:organization_machine_id/alerts/:id
  def show
    authorize @alert
    render json: AlertSerializer.new(@alert).serializable_hash
  end

  # POST /organizations/:organization_id/organization_machines/:organization_machine_id/alerts/:id/acknowledge
  def acknowledge
    authorize @alert, :acknowledge?

    if @alert.active? || @alert.acknowledged?
      @alert.update!(
        status: :acknowledged,
        resolved_by: current_user,
        acknowledgment_note: params[:note],
        resolved_at: Time.current
      )

      MachineChannel.broadcast_alert_update(@machine.id, @alert)

      # Notify the user's manager if one is assigned
      if current_user.operator? && current_user.manager
        notif = Notification.create!(
          user: current_user.manager,
          notification_type: "alert_acknowledged",
          message: "#{current_user.first_name} #{current_user.last_name} acknowledged a #{@alert.severity} alert on #{@machine.nickname}.",
          navigation_target: {route: "/machines/#{@machine.id}/alerts/#{@alert.id}"}
        )
        UserChannel.broadcast_notification(notif)
      end

      render json: AlertSerializer.new(@alert.reload).serializable_hash
    else
      render json: {errors: ["Alert is already resolved"]}, status: :unprocessable_content
    end
  end

  private

  def set_machine
    org = Organization.find(params[:organization_id])
    @machine = org.organization_machines.find(params[:organization_machine_id])
  end

  def set_alert
    @alert = @machine.alerts.find(params[:id])
  end
end
