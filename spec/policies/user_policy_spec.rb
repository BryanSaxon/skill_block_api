require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }

  let(:owner) { create(:owner_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:other_org_user) { create(:user, organization: create(:organization)) }

  subject { described_class }

  permissions :index? do
    it "grants access to owner" do
      expect(subject).to permit(owner, operator)
    end

    it "grants access to admin" do
      expect(subject).to permit(admin, operator)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, operator)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, operator)
    end
  end

  permissions :show? do
    it "grants access to owner for any user" do
      expect(subject).to permit(owner, other_org_user)
    end

    it "grants access to a user viewing someone in the same org" do
      expect(subject).to permit(admin, operator)
    end

    it "grants access to a user viewing themselves" do
      expect(subject).to permit(operator, operator)
    end

    it "denies access to a user viewing someone in a different org" do
      expect(subject).not_to permit(operator, other_org_user)
    end
  end

  permissions :create? do
    it "grants access to owner" do
      expect(subject).to permit(owner, operator)
    end

    it "grants access to admin" do
      expect(subject).to permit(admin, operator)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, operator)
    end
  end

  permissions :update? do
    it "grants access to owner for any user" do
      expect(subject).to permit(owner, other_org_user)
    end

    it "grants access to admin for users in their org" do
      expect(subject).to permit(admin, operator)
    end

    it "grants access to a user updating themselves" do
      expect(subject).to permit(operator, operator)
    end

    it "denies access to admin for users in a different org" do
      expect(subject).not_to permit(admin, other_org_user)
    end
  end

  permissions :destroy? do
    it "grants access to owner for any user" do
      expect(subject).to permit(owner, operator)
    end

    it "grants access to admin for other users in their org" do
      expect(subject).to permit(admin, operator)
    end

    it "denies admin from deleting themselves" do
      expect(subject).not_to permit(admin, admin)
    end

    it "denies access to admin for users in a different org" do
      expect(subject).not_to permit(admin, other_org_user)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, manager)
    end
  end

  describe UserPolicy::Scope do
    it "returns all users for owner" do
      operator
      other_org_user
      scope = described_class.new(owner, User).resolve
      expect(scope).to include(operator, other_org_user)
    end

    it "returns only users in the same org for non-owner" do
      operator
      other_org_user
      scope = described_class.new(admin, User).resolve
      expect(scope).to include(operator)
      expect(scope).not_to include(other_org_user)
    end
  end
end
