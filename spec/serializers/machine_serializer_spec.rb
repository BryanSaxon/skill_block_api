require "rails_helper"

RSpec.describe MachineSerializer do
  let(:machine) { create(:machine) }
  let(:serialized) { described_class.new(machine).serializable_hash }
  let(:attributes) { serialized[:data][:attributes] }

  it "includes name, model_number, and description" do
    expect(attributes[:name]).to eq(machine.name)
    expect(attributes[:model_number]).to eq(machine.model_number)
    expect(attributes[:description]).to eq(machine.description)
  end

  it "includes a nil manual_url when no manual is attached" do
    expect(attributes[:manual_url]).to be_nil
  end

  it "includes a manual_url when a manual is attached" do
    machine.manual.attach(io: StringIO.new("%PDF fake"), filename: "manual.pdf", content_type: "application/pdf")
    expect(attributes[:manual_url]).to be_present
  end

  it "does not expose internal fields" do
    expect(attributes.keys).not_to include(:created_at, :updated_at)
  end
end
