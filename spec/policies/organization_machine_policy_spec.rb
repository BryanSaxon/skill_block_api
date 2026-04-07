require "rails_helper"

RSpec.describe OrganizationMachinePolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:other_operator) { create(:user, organization: other_org) }

  let(:org_machine) { create(:organization_machine, organization: other_org) }

  subject { described_class }

  permissions :index? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, org_machine)
    end

    it "grants access to admin in same org" do
      expect(subject).to permit(admin, org_machine)
    end

    it "grants access to manager in same org" do
      expect(subject).to permit(manager, org_machine)
    end

    it "grants access to operator in same org" do
      expect(subject).to permit(operator, org_machine)
    end
  end

  permissions :show? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, org_machine)
    end

    it "grants access to admin in same org" do
      expect(subject).to permit(admin, org_machine)
    end

    it "grants access to assigned operator" do
      create(:user_organization_machine, user: operator, organization_machine: org_machine)
      expect(subject).to permit(operator, org_machine)
    end

    it "denies access to unassigned operator in same org" do
      expect(subject).not_to permit(other_operator, org_machine)
    end
  end

  permissions :create?, :destroy? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, org_machine)
    end

    it "grants access to admin in same org" do
      expect(subject).to permit(admin, org_machine)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, org_machine)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, org_machine)
    end
  end

  permissions :update? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, org_machine)
    end

    it "grants access to admin in same org" do
      expect(subject).to permit(admin, org_machine)
    end

    it "grants access to manager in same org" do
      expect(subject).to permit(manager, org_machine)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, org_machine)
    end
  end

  describe OrganizationMachinePolicy::Scope do
    let(:other_org_machine) { create(:organization_machine) }

    it "returns all organization machines for admin org user" do
      org_machine
      other_org_machine
      scope = described_class.new(admin_org_user, OrganizationMachine).resolve
      expect(scope).to include(org_machine, other_org_machine)
    end

    it "returns only same-org machines for admin" do
      org_machine
      other_org_machine
      scope = described_class.new(admin, OrganizationMachine).resolve
      expect(scope).to contain_exactly(org_machine)
    end

    it "returns only assigned machines for operator" do
      org_machine
      other_org_machine
      create(:user_organization_machine, user: operator, organization_machine: org_machine)
      scope = described_class.new(operator, OrganizationMachine).resolve
      expect(scope).to contain_exactly(org_machine)
    end
  end
end
