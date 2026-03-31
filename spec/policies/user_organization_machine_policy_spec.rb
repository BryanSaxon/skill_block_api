require "rails_helper"

RSpec.describe UserOrganizationMachinePolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:owner) { create(:owner_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }

  let(:org_machine) { create(:organization_machine, organization: other_org) }
  let(:uom) { create(:user_organization_machine, organization_machine: org_machine) }

  subject { described_class }

  permissions :index?, :show? do
    it "grants access to owner" do
      expect(subject).to permit(owner, uom)
    end

    it "grants access to admin" do
      expect(subject).to permit(admin, uom)
    end

    it "grants access to manager" do
      expect(subject).to permit(manager, uom)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, uom)
    end
  end

  permissions :create?, :destroy? do
    it "grants access to owner" do
      expect(subject).to permit(owner, uom)
    end

    it "grants access to admin in same org" do
      expect(subject).to permit(admin, uom)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, uom)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, uom)
    end
  end

  describe UserOrganizationMachinePolicy::Scope do
    it "returns all records for owner" do
      uom
      scope = described_class.new(owner, UserOrganizationMachine).resolve
      expect(scope).to include(uom)
    end

    it "returns only records within the user's org for admin" do
      uom
      create(:user_organization_machine)
      scope = described_class.new(admin, UserOrganizationMachine).resolve
      expect(scope).to contain_exactly(uom)
    end
  end
end
