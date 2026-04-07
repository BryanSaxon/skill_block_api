class InvitationSerializer
  include JSONAPI::Serializer

  attributes :email, :role, :expires_at, :accepted_at

  attribute :status do |invitation|
    if invitation.accepted?
      "accepted"
    elsif invitation.expired?
      "expired"
    else
      "pending"
    end
  end

  belongs_to :organization
end
