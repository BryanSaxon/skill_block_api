require "rails_helper"

RSpec.describe UserOrganizationMachine, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organization_machine) }
  end

  describe "validations" do
    it "is invalid when the same user is assigned to the same machine twice" do
      uom = create(:user_organization_machine)
      duplicate = build(:user_organization_machine, user: uom.user, organization_machine: uom.organization_machine)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "is valid when the same user is assigned to a different machine" do
      user = create(:user)
      create(:user_organization_machine, user: user)
      expect(build(:user_organization_machine, user: user)).to be_valid
    end
  end
end
