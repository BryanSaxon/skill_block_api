class MachineParameterSerializer
  include JSONAPI::Serializer

  attributes :name, :unit, :normal_min, :normal_max,
    :warning_threshold, :critical_threshold, :display_order

  belongs_to :organization_machine
end
