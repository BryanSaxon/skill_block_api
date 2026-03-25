class UserSerializer
  include JSONAPI::Serializer

  attributes :first_name, :last_name, :email, :role

  attribute :avatar_url do |user|
    next unless user.avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
  end

  belongs_to :organization
end
