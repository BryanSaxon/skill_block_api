class MachineSerializer
  include JSONAPI::Serializer

  attributes :name, :model_number, :description

  attribute :manual_url do |machine|
    next unless machine.manual.attached?

    Rails.application.routes.url_helpers.rails_blob_path(machine.manual, only_path: true)
  end

  belongs_to :manufacturer
end
