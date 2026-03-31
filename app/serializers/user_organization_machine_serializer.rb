class UserOrganizationMachineSerializer
  include JSONAPI::Serializer

  belongs_to :user
  belongs_to :organization_machine
end
