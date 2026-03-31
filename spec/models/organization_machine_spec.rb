require "rails_helper"

RSpec.describe OrganizationMachine, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:machine) }
    it { is_expected.to have_many(:user_organization_machines).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_organization_machines) }

    it "has a sops attachment" do
      expect(OrganizationMachine.new).to respond_to(:sops)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:vin) }

    it "is invalid with a duplicate vin for the same organization" do
      org = create(:organization)
      create(:organization_machine, organization: org, vin: "VIN-001")
      duplicate = build(:organization_machine, organization: org, vin: "VIN-001")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:vin]).to include("has already been taken")
    end

    it "is valid with the same vin for a different organization" do
      create(:organization_machine, vin: "VIN-001")
      machine = build(:organization_machine, vin: "VIN-001")
      expect(machine).to be_valid
    end
  end

  describe "AASM state machine" do
    subject(:om) { create(:organization_machine) }

    it "starts in active state" do
      expect(om).to be_active
    end

    it "transitions from active to inactive via deactivate" do
      om.deactivate!
      expect(om).to be_inactive
    end

    it "transitions from active to maintenance via begin_maintenance" do
      om.begin_maintenance!
      expect(om).to be_maintenance
    end

    it "transitions from maintenance to active via complete_maintenance" do
      om.begin_maintenance!
      om.complete_maintenance!
      expect(om).to be_active
    end

    it "transitions from inactive to active via activate" do
      om.deactivate!
      om.activate!
      expect(om).to be_active
    end

    it "raises AASM::InvalidTransition for invalid transitions" do
      expect { om.complete_maintenance! }.to raise_error(AASM::InvalidTransition)
    end
  end
end
