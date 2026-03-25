require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:destroy) }

    it "has a logo attachment" do
      expect(Organization.new).to respond_to(:logo)
    end
  end

  describe "validations" do
    describe "name" do
      it { is_expected.to validate_presence_of(:name) }

      it "is invalid with a duplicate name" do
        create(:organization, name: "Acme Corp")
        duplicate = build(:organization, name: "Acme Corp")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end

      it "is valid with a unique name" do
        expect(build(:organization)).to be_valid
      end
    end

    describe "logo" do
      it "is valid without a logo" do
        expect(build(:organization)).to be_valid
      end

      it "is valid with a PNG logo" do
        org = build(:organization)
        org.logo.attach(io: StringIO.new("fake png"), filename: "logo.png", content_type: "image/png")
        expect(org).to be_valid
      end

      it "is valid with a JPEG logo" do
        org = build(:organization)
        org.logo.attach(io: StringIO.new("fake jpg"), filename: "logo.jpg", content_type: "image/jpeg")
        expect(org).to be_valid
      end

      it "is valid with an SVG logo" do
        org = build(:organization)
        org.logo.attach(io: StringIO.new("<svg></svg>"), filename: "logo.svg", content_type: "image/svg+xml")
        expect(org).to be_valid
      end

      it "is invalid with a non-image file" do
        org = build(:organization)
        org.logo.attach(io: StringIO.new("not an image"), filename: "doc.pdf", content_type: "application/pdf")
        expect(org).not_to be_valid
        expect(org.errors[:logo]).to include("must be a PNG, JPG, or SVG")
      end
    end
  end

  describe "constants" do
    it "has SKILL_BLOCK_NAME set to 'Skill Block'" do
      expect(Organization::SKILL_BLOCK_NAME).to eq("Skill Block")
    end
  end
end
