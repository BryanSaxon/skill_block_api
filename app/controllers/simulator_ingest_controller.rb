# SimulatorIngestController — receives POST requests from the standalone simulator app.
#
# Auth: X-Simulator-Key header must match SIMULATOR_API_KEY env var.
# All actions bypass Pundit (machine writes are internal to the demo pipeline).
class SimulatorIngestController < ApplicationController
  skip_before_action :require_authentication
  before_action :authenticate_simulator!

  # POST /simulator/telemetry
  # Body: { machine_id: 9, readings: [{ parameter_name: "drum_speed", value: 82.1, recorded_at: "..." }] }
  def telemetry
    machine = OrganizationMachine.find(params[:machine_id])
    readings_params = params.require(:readings)

    rows = readings_params.map do |r|
      {
        organization_machine_id: machine.id,
        parameter_name: r[:parameter_name],
        value: r[:value].to_f,
        recorded_at: Time.parse(r[:recorded_at].to_s),
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    TelemetryReading.insert_all!(rows)

    # Derive machine health status from readings and broadcast
    status = derive_status(machine, readings_params)
    MachineChannel.broadcast_telemetry(machine.id, rows.map { |r| r.slice(:parameter_name, :value, :recorded_at) })
    MachineChannel.broadcast_status(machine.id, status)

    head :no_content
  end

  # POST /simulator/fault
  # Body: { machine_id: 9, fault_type: "warning" | "critical" }
  def fault
    machine = OrganizationMachine.find(params[:machine_id])
    fault_type = params[:fault_type]

    unless %w[warning critical].include?(fault_type)
      render json: {error: "Invalid fault_type"}, status: :unprocessable_content
      return
    end

    # Find the motor_temperature parameter for threshold values
    param = machine.machine_parameters.find_by(name: "motor_temperature")
    threshold = (fault_type == "critical") ? param&.critical_threshold : param&.warning_threshold
    triggered_value = (fault_type == "critical") ? 108.0 : 100.0

    # Avoid duplicate active alerts for same parameter
    unless machine.alerts.open.where(parameter_name: "motor_temperature").exists?
      alert = machine.alerts.create!(
        parameter_name: "motor_temperature",
        triggered_value: triggered_value,
        threshold_value: threshold || triggered_value,
        severity: fault_type,
        status: :active,
        triggered_at: Time.current
      )

      MachineChannel.broadcast_alert(machine.id, alert)
      broadcast_alert_notifications(machine, alert)
    end

    head :no_content
  end

  # POST /simulator/resolve_alerts
  # Body: { machine_id: 9 }
  def resolve_alerts
    machine = OrganizationMachine.find(params[:machine_id])
    machine.alerts.open.each do |alert|
      alert.update!(status: :resolved, resolved_at: Time.current)
      MachineChannel.broadcast_alert_update(machine.id, alert)
    end
    head :no_content
  end

  # POST /simulator/reset
  # Body: { machine_id: 9 }
  def reset
    machine = OrganizationMachine.find(params[:machine_id])
    machine.alerts.open.update_all(status: "resolved", resolved_at: Time.current.utc)
    MachineChannel.broadcast_status(machine.id, "normal")
    head :no_content
  end

  private

  def authenticate_simulator!
    key = request.headers["X-Simulator-Key"].to_s
    expected = ENV.fetch("SIMULATOR_API_KEY", "")

    if expected.blank? || !ActiveSupport::SecurityUtils.secure_compare(key, expected)
      render json: {error: "Unauthorized"}, status: :unauthorized
    end
  end

  def derive_status(machine, readings)
    params = machine.machine_parameters.index_by(&:name)
    has_critical = false
    has_warning = false

    readings.each do |r|
      p = params[r[:parameter_name].to_s]
      next unless p
      val = r[:value].to_f
      has_critical = true if p.critical_threshold && val >= p.critical_threshold.to_f
      has_warning = true if p.warning_threshold && val >= p.warning_threshold.to_f
    end

    if has_critical then "critical"
    elsif has_warning then "warning"
    else "normal"
    end
  end

  def broadcast_alert_notifications(machine, alert)
    # Notify all operators assigned to this machine
    machine.users.where(role: :operator).each do |operator|
      notif = Notification.create!(
        user: operator,
        notification_type: "alert_fired",
        message: "#{alert.severity.capitalize} alert on #{machine.nickname}: #{alert.parameter_name.tr("_", " ")} is #{alert.triggered_value.to_f.round(1)}.",
        navigation_target: {route: "/machines/#{machine.id}/alerts/#{alert.id}"}
      )
      UserChannel.broadcast_notification(notif)
    end
  end
end
