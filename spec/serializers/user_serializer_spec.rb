require "rails_helper"

RSpec.describe UserSerializer do
  let(:user) { create(:user) }
  let(:serialized) { described_class.new(user).serializable_hash }
  let(:attributes) { serialized[:data][:attributes] }

  it "includes first_name" do
    expect(attributes[:first_name]).to eq(user.first_name)
  end

  it "includes last_name" do
    expect(attributes[:last_name]).to eq(user.last_name)
  end

  it "includes email" do
    expect(attributes[:email]).to eq(user.email)
  end

  it "includes role" do
    expect(attributes[:role]).to eq(user.role)
  end

  it "includes a nil avatar_url when no avatar is attached" do
    expect(attributes[:avatar_url]).to be_nil
  end

  it "includes an avatar_url when an avatar is attached" do
    user.avatar.attach(io: StringIO.new("fake png"), filename: "avatar.png", content_type: "image/png")
    expect(attributes[:avatar_url]).to be_present
  end

  it "does not expose password_digest" do
    expect(attributes.keys).not_to include(:password_digest)
  end

  it "does not expose internal fields" do
    expect(attributes.keys).not_to include(:created_at, :updated_at)
  end

  it "includes the organization relationship" do
    relationships = serialized[:data][:relationships]
    expect(relationships[:organization][:data]).to include(id: user.organization_id.to_s, type: :organization)
  end
end
