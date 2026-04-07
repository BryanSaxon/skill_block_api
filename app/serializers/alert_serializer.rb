class AlertSerializer
  include JSONAPI::Serializer

  attributes :parameter_name, :triggered_value, :threshold_value,
             :severity, :status, :triggered_at, :resolved_at, :acknowledgment_note

  belongs_to :organization_machine
  belongs_to :resolved_by, serializer: UserSerializer, record_type: :user
end
