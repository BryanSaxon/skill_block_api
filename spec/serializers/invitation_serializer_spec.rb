require "rails_helper"

RSpec.describe InvitationSerializer do
  let(:organization) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user) }
  let(:invitation) { create(:invitation, organization: organization, invited_by: admin_org_user) }
  let(:serialized) { described_class.new(invitation).serializable_hash }
  let(:attributes) { serialized[:data][:attributes] }

  it "includes email" do
    expect(attributes[:email]).to eq(invitation.email)
  end

  it "includes role" do
    expect(attributes[:role]).to eq(invitation.role)
  end

  it "includes expires_at" do
    expect(attributes[:expires_at]).to be_present
  end

  it "includes accepted_at" do
    expect(attributes.key?(:accepted_at)).to be true
  end

  it "includes status" do
    expect(attributes[:status]).to be_present
  end

  it "does not expose the token attribute" do
    expect(attributes.keys).not_to include(:token)
  end

  it "does not expose internal fields" do
    expect(attributes.keys).not_to include(:created_at, :updated_at)
  end

  describe "status attribute" do
    it "is 'pending' for a fresh invitation" do
      expect(attributes[:status]).to eq("pending")
    end

    it "is 'accepted' for an accepted invitation" do
      accepted_invitation = create(:invitation, :accepted, organization: organization, invited_by: admin_org_user)
      serialized = described_class.new(accepted_invitation).serializable_hash
      expect(serialized[:data][:attributes][:status]).to eq("accepted")
    end

    it "is 'expired' for an expired invitation" do
      expired_invitation = create(:invitation, :expired, organization: organization, invited_by: admin_org_user)
      serialized = described_class.new(expired_invitation).serializable_hash
      expect(serialized[:data][:attributes][:status]).to eq("expired")
    end
  end

  describe "relationships" do
    it "includes the organization relationship" do
      expect(serialized[:data][:relationships][:organization]).to be_present
    end
  end
end
