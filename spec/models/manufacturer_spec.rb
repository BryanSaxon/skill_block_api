require "rails_helper"

RSpec.describe Manufacturer, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:machines).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "is invalid with a duplicate name" do
      create(:manufacturer, name: "Acme")
      duplicate = build(:manufacturer, name: "Acme")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "is valid with a unique name" do
      expect(build(:manufacturer)).to be_valid
    end
  end
end
