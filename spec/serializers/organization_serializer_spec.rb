require "rails_helper"

RSpec.describe OrganizationSerializer do
  let(:organization) { create(:organization) }
  let(:serialized) { described_class.new(organization).serializable_hash }
  let(:attributes) { serialized[:data][:attributes] }

  it "includes the name" do
    expect(attributes[:name]).to eq(organization.name)
  end

  it "includes a nil logo_url when no logo is attached" do
    expect(attributes[:logo_url]).to be_nil
  end

  it "includes a logo_url when a logo is attached" do
    organization.logo.attach(io: StringIO.new("fake png"), filename: "logo.png", content_type: "image/png")
    expect(attributes[:logo_url]).to be_present
  end

  it "does not expose internal fields" do
    expect(attributes.keys).not_to include(:created_at, :updated_at)
  end
end
