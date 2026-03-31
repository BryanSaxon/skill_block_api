require "rails_helper"

RSpec.describe ManufacturerSerializer do
  let(:manufacturer) { create(:manufacturer) }
  let(:serialized) { described_class.new(manufacturer).serializable_hash }
  let(:attributes) { serialized[:data][:attributes] }

  it "includes the name" do
    expect(attributes[:name]).to eq(manufacturer.name)
  end

  it "does not expose internal fields" do
    expect(attributes.keys).not_to include(:created_at, :updated_at)
  end
end
