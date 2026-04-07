class TelemetryReadingSerializer
  include JSONAPI::Serializer

  attributes :parameter_name, :value, :recorded_at

  belongs_to :organization_machine
end
