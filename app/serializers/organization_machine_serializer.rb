class OrganizationMachineSerializer
  include JSONAPI::Serializer

  attributes :vin, :nickname, :status

  attribute :sop_urls do |organization_machine|
    organization_machine.sops.map do |sop|
      Rails.application.routes.url_helpers.rails_blob_path(sop, only_path: true)
    end
  end

  # Derived health status from open alerts: "normal" | "warning" | "critical" | "unknown"
  attribute :current_status do |machine|
    open_alerts = machine.alerts.open
    if open_alerts.where(severity: :critical).exists?
      "critical"
    elsif open_alerts.where(severity: :warning).exists?
      "warning"
    elsif machine.active?
      "normal"
    else
      "unknown"
    end
  end

  # Latest reading per parameter — { "drum_speed": { value: 82.1, recorded_at: "..." }, ... }
  attribute :current_readings do |machine|
    machine.machine_parameters.each_with_object({}) do |param, hash|
      reading = machine.telemetry_readings
                       .for_parameter(param.name)
                       .recent_first
                       .limit(1)
                       .first
      hash[param.name] = reading ? { value: reading.value, recorded_at: reading.recorded_at.iso8601 } : nil
    end
  end

  # Assigned operator name (used by Flutter operator app bar)
  attribute :assigned_operator_name do |machine|
    nil  # populated server-side when context includes a specific user
  end

  belongs_to :organization
  belongs_to :machine
end
