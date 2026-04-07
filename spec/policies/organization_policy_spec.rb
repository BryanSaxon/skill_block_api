require "rails_helper"

RSpec.describe OrganizationPolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }

  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }

  subject { described_class }

  permissions :index? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, other_org)
    end

    it "grants access to admin" do
      expect(subject).to permit(admin, other_org)
    end

    it "grants access to manager" do
      expect(subject).to permit(manager, other_org)
    end

    it "grants access to operator" do
      expect(subject).to permit(operator, other_org)
    end
  end

  permissions :show? do
    it "grants access to admin org user for any org" do
      expect(subject).to permit(admin_org_user, other_org)
    end

    it "grants access to a user viewing their own org" do
      expect(subject).to permit(admin, other_org)
    end

    it "denies access to a user viewing a different org" do
      expect(subject).not_to permit(admin, skill_block_org)
    end
  end

  permissions :create? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, other_org)
    end

    it "denies access to admin" do
      expect(subject).not_to permit(admin, other_org)
    end
  end

  permissions :update? do
    it "grants access to admin org user for any org" do
      expect(subject).to permit(admin_org_user, other_org)
    end

    it "grants access to admin for their own org" do
      expect(subject).to permit(admin, other_org)
    end

    it "denies access to admin for a different org" do
      expect(subject).not_to permit(admin, skill_block_org)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, other_org)
    end
  end

  permissions :destroy? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, other_org)
    end

    it "denies access to admin" do
      expect(subject).not_to permit(admin, other_org)
    end
  end

  describe OrganizationPolicy::Scope do
    it "returns all organizations for admin org user" do
      other_org
      skill_block_org
      scope = described_class.new(admin_org_user, Organization).resolve
      expect(scope).to include(other_org, skill_block_org)
    end

    it "returns only the user's organization for non-owner" do
      other_org
      skill_block_org
      scope = described_class.new(admin, Organization).resolve
      expect(scope).to contain_exactly(other_org)
    end
  end
end
