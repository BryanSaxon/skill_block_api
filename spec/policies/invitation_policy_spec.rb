require "rails_helper"

RSpec.describe InvitationPolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:another_org) { create(:organization) }

  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:client_admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:other_org_admin) { create(:admin_user, organization: another_org) }

  let(:invitation) { create(:invitation, organization: other_org, invited_by: admin_org_user) }

  subject { described_class }

  permissions :index? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, invitation)
    end

    it "grants access to client admin in the same organization" do
      expect(subject).to permit(client_admin, invitation)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, invitation)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, invitation)
    end

    it "denies access to client admin in a different organization" do
      expect(subject).not_to permit(other_org_admin, invitation)
    end
  end

  permissions :create? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, invitation)
    end

    it "grants access to client admin in the same organization" do
      expect(subject).to permit(client_admin, invitation)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, invitation)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, invitation)
    end

    it "denies access to client admin in a different organization" do
      expect(subject).not_to permit(other_org_admin, invitation)
    end
  end

  permissions :destroy? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, invitation)
    end

    it "grants access to client admin in the same organization" do
      expect(subject).to permit(client_admin, invitation)
    end

    it "denies access to manager" do
      expect(subject).not_to permit(manager, invitation)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, invitation)
    end

    it "denies access to client admin in a different organization" do
      expect(subject).not_to permit(other_org_admin, invitation)
    end
  end

  describe InvitationPolicy::Scope do
    let(:own_org_invitation) { create(:invitation, organization: other_org, invited_by: admin_org_user) }
    let(:another_org_invitation) { create(:invitation, organization: another_org, invited_by: admin_org_user) }

    it "returns all invitations for admin org user" do
      own_org_invitation
      another_org_invitation
      scope = described_class.new(admin_org_user, Invitation).resolve
      expect(scope).to include(own_org_invitation, another_org_invitation)
    end

    it "returns only the user's own organization invitations for client admin" do
      own_org_invitation
      another_org_invitation
      scope = described_class.new(client_admin, Invitation).resolve
      expect(scope).to include(own_org_invitation)
      expect(scope).not_to include(another_org_invitation)
    end
  end
end
