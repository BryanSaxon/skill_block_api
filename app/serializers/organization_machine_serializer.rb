class OrganizationMachineSerializer
  include JSONAPI::Serializer

  attributes :vin, :nickname, :status

  attribute :sop_urls do |organization_machine|
    organization_machine.sops.map do |sop|
      Rails.application.routes.url_helpers.rails_blob_path(sop, only_path: true)
    end
  end

  belongs_to :organization
  belongs_to :machine
end
