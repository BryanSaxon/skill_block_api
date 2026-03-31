require "rails_helper"

RSpec.describe OrganizationMachineSerializer do
  let(:organization_machine) { create(:organization_machine, nickname: "Line 3") }
  let(:serialized) { described_class.new(organization_machine).serializable_hash }
  let(:attributes) { serialized[:data][:attributes] }

  it "includes vin, nickname, and status" do
    expect(attributes[:vin]).to eq(organization_machine.vin)
    expect(attributes[:nickname]).to eq("Line 3")
    expect(attributes[:status]).to eq("active")
  end

  it "includes an empty sop_urls array when no SOPs are attached" do
    expect(attributes[:sop_urls]).to eq([])
  end

  it "includes sop_urls when SOPs are attached" do
    organization_machine.sops.attach(
      io: StringIO.new("%PDF fake"),
      filename: "sop.pdf",
      content_type: "application/pdf"
    )
    serialized_with_sop = described_class.new(organization_machine).serializable_hash
    expect(serialized_with_sop[:data][:attributes][:sop_urls].length).to eq(1)
  end

  it "does not expose internal fields" do
    expect(attributes.keys).not_to include(:created_at, :updated_at)
  end
end
