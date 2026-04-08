class TelemetryReadingsController < ApplicationController
  before_action :set_machine

  # GET /organizations/:organization_id/organization_machines/:organization_machine_id/telemetry
  # Query params:
  #   parameter   — filter to one parameter name (optional)
  #   limit       — max readings (default 150, max 500)
  def index
    authorize TelemetryReading

    limit = [[params.fetch(:limit, 150).to_i, 1].max, 500].min
    readings = policy_scope(TelemetryReading)
      .where(organization_machine: @machine)
      .recent_first
      .limit(limit)

    readings = readings.for_parameter(params[:parameter]) if params[:parameter].present?

    render json: TelemetryReadingSerializer.new(readings).serializable_hash
  end

  private

  def set_machine
    org = Organization.find(params[:organization_id])
    @machine = org.organization_machines.find(params[:organization_machine_id])
  end
end
