require "rails_helper"

RSpec.describe UserOrganizationMachineSerializer do
  let(:uom) { create(:user_organization_machine) }
  let(:serialized) { described_class.new(uom).serializable_hash }

  it "includes relationship links to user and organization_machine" do
    relationships = serialized[:data][:relationships]
    expect(relationships[:user][:data][:id]).to eq(uom.user_id.to_s)
    expect(relationships[:organization_machine][:data][:id]).to eq(uom.organization_machine_id.to_s)
  end
end
