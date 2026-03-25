class OrganizationSerializer
  include JSONAPI::Serializer

  attributes :name

  attribute :logo_url do |organization|
    next unless organization.logo.attached?

    Rails.application.routes.url_helpers.rails_blob_path(organization.logo, only_path: true)
  end
end
