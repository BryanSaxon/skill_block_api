require "rails_helper"

RSpec.describe Machine, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:manufacturer) }
    it { is_expected.to have_many(:organization_machines).dependent(:destroy) }

    it "has a manual attachment" do
      expect(Machine.new).to respond_to(:manual)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:model_number) }

    it "is invalid with a duplicate model_number for the same manufacturer" do
      manufacturer = create(:manufacturer)
      create(:machine, manufacturer: manufacturer, model_number: "X100")
      duplicate = build(:machine, manufacturer: manufacturer, model_number: "X100")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:model_number]).to include("has already been taken")
    end

    it "is valid with the same model_number for a different manufacturer" do
      create(:machine, model_number: "X100")
      machine = build(:machine, model_number: "X100")
      expect(machine).to be_valid
    end

    it "is valid without a manual" do
      expect(build(:machine)).to be_valid
    end

    it "is invalid when manual is not a PDF" do
      machine = build(:machine)
      machine.manual.attach(io: StringIO.new("not a pdf"), filename: "doc.png", content_type: "image/png")
      expect(machine).not_to be_valid
      expect(machine.errors[:manual]).to include("must be a PDF")
    end
  end
end
