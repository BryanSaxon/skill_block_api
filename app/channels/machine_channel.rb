# MachineChannel — real-time telemetry and alert updates for a single machine.
#
# Flutter subscribes with: { "channel": "MachineChannel", "machine_id": 123 }
# Broadcasts:
#   telemetry_update  — new batch of parameter readings
#   alert_created     — a new alert was triggered
#   alert_updated     — an alert was acknowledged or resolved
#   status_update     — machine health status changed (normal/warning/critical/unknown)
class MachineChannel < ApplicationCable::Channel
  def subscribed
    machine = authorized_machine
    if machine
      stream_from "machine_#{machine.id}"
    else
      reject
    end
  end

  def unsubscribed
    # streams are cleaned up automatically
  end

  # Broadcast helpers — called from controllers/jobs after mutations.

  def self.broadcast_telemetry(machine_id, readings)
    ActionCable.server.broadcast("machine_#{machine_id}", {
      type: "telemetry_update",
      readings: readings,
      broadcast_at: Time.current.iso8601
    })
  end

  def self.broadcast_alert(machine_id, alert)
    ActionCable.server.broadcast("machine_#{machine_id}", {
      type: "alert_created",
      alert: alert_payload(alert),
      broadcast_at: Time.current.iso8601
    })
  end

  def self.broadcast_alert_update(machine_id, alert)
    ActionCable.server.broadcast("machine_#{machine_id}", {
      type: "alert_updated",
      alert: alert_payload(alert),
      broadcast_at: Time.current.iso8601
    })
  end

  def self.broadcast_status(machine_id, status)
    ActionCable.server.broadcast("machine_#{machine_id}", {
      type: "status_update",
      status: status,   # "normal" | "warning" | "critical" | "unknown"
      broadcast_at: Time.current.iso8601
    })
  end

  private

  def authorized_machine
    machine_id = params[:machine_id]
    return nil unless machine_id.present?

    machine = OrganizationMachine.find_by(id: machine_id)
    return nil unless machine

    policy = OrganizationMachinePolicy.new(current_user, machine)
    policy.show? ? machine : nil
  end

  def self.alert_payload(alert)
    {
      id: alert.id,
      parameter_name: alert.parameter_name,
      triggered_value: alert.triggered_value,
      threshold_value: alert.threshold_value,
      severity: alert.severity,
      status: alert.status,
      triggered_at: alert.triggered_at&.iso8601,
      resolved_at: alert.resolved_at&.iso8601,
      acknowledgment_note: alert.acknowledgment_note
    }
  end
end
