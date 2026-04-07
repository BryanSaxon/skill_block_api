require "rails_helper"

RSpec.describe MachinePolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:machine) { create(:machine) }

  subject { described_class }

  permissions :index?, :show? do
    it "grants access to all roles" do
      expect(subject).to permit(admin_org_user, machine)
      expect(subject).to permit(admin, machine)
      expect(subject).to permit(operator, machine)
    end
  end

  permissions :create?, :update?, :destroy? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, machine)
    end

    it "denies access to admin" do
      expect(subject).not_to permit(admin, machine)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, machine)
    end
  end

  describe MachinePolicy::Scope do
    it "returns all machines for any user" do
      machine
      scope = described_class.new(admin, Machine).resolve
      expect(scope).to include(machine)
    end
  end
end
