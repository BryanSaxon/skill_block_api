require "rails_helper"

RSpec.describe Invitation, type: :model do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:invited_by) { create(:admin_org_user, organization: skill_block_org) }
  let(:client_org) { create(:organization) }

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:invited_by).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }

    it "requires a token to be present after creation" do
      invitation = create(:invitation, organization: client_org, invited_by: invited_by)
      invitation.token = nil
      expect(invitation).not_to be_valid
    end

    it "requires expires_at to be present after creation" do
      invitation = create(:invitation, organization: client_org, invited_by: invited_by)
      invitation.expires_at = nil
      expect(invitation).not_to be_valid
    end

    it "validates email format" do
      invitation = build(:invitation, email: "not-an-email", organization: client_org, invited_by: invited_by)
      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to be_present
    end

    it "is valid with a properly formatted email" do
      expect(build(:invitation, organization: client_org, invited_by: invited_by)).to be_valid
    end

    it "validates uniqueness of token" do
      existing = create(:invitation, organization: client_org, invited_by: invited_by)
      duplicate = build(:invitation, organization: client_org, invited_by: invited_by, token: existing.token)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:token]).to include("has already been taken")
    end

    describe "email_not_already_registered" do
      it "is invalid when a user with that email already exists" do
        user = create(:user, organization: client_org)
        invitation = build(:invitation, email: user.email, organization: client_org, invited_by: invited_by)
        expect(invitation).not_to be_valid
        expect(invitation.errors[:email]).to include("already has an account")
      end

      it "is valid when no user exists with that email" do
        expect(build(:invitation, organization: client_org, invited_by: invited_by)).to be_valid
      end
    end

    describe "role_valid_for_org_type" do
      it "is invalid when org is admin type and role is not admin" do
        invitation = build(:invitation, organization: skill_block_org, invited_by: invited_by, role: :operator)
        expect(invitation).not_to be_valid
        expect(invitation.errors[:role]).to include("admin org users must have admin role")
      end

      it "is valid when org is admin type and role is admin" do
        invitation = build(:invitation, organization: skill_block_org, invited_by: invited_by, role: :admin)
        expect(invitation).to be_valid
      end

      it "is valid when org is client type with any role" do
        expect(build(:invitation, organization: client_org, invited_by: invited_by, role: :operator)).to be_valid
        expect(build(:invitation, organization: client_org, invited_by: invited_by, role: :manager)).to be_valid
        expect(build(:invitation, organization: client_org, invited_by: invited_by, role: :admin)).to be_valid
      end
    end
  end

  describe "before_validation on create" do
    it "auto-generates a token" do
      invitation = create(:invitation, organization: client_org, invited_by: invited_by)
      expect(invitation.token).to be_present
      expect(invitation.token.length).to eq(64)
    end

    it "does not overwrite an existing token" do
      invitation = create(:invitation, organization: client_org, invited_by: invited_by, token: nil)
      expect(invitation.token).to be_present
    end

    it "sets expires_at to approximately 48 hours from now" do
      invitation = create(:invitation, organization: client_org, invited_by: invited_by, expires_at: nil)
      expect(invitation.expires_at).to be_within(1.minute).of(48.hours.from_now)
    end

    it "does not overwrite an existing expires_at" do
      custom_time = 72.hours.from_now
      invitation = create(:invitation, organization: client_org, invited_by: invited_by, expires_at: custom_time)
      expect(invitation.expires_at).to be_within(1.second).of(custom_time)
    end
  end

  describe "#pending?" do
    it "returns true when not accepted and not expired" do
      invitation = build(:invitation, organization: client_org, invited_by: invited_by)
      expect(invitation.pending?).to be true
    end

    it "returns false when accepted" do
      invitation = build(:invitation, :accepted, organization: client_org, invited_by: invited_by)
      expect(invitation.pending?).to be false
    end

    it "returns false when expired" do
      invitation = build(:invitation, :expired, organization: client_org, invited_by: invited_by)
      expect(invitation.pending?).to be false
    end
  end

  describe "#accepted?" do
    it "returns true when accepted_at is present" do
      invitation = build(:invitation, :accepted, organization: client_org, invited_by: invited_by)
      expect(invitation.accepted?).to be true
    end

    it "returns false when accepted_at is nil" do
      invitation = build(:invitation, organization: client_org, invited_by: invited_by)
      expect(invitation.accepted?).to be false
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation = build(:invitation, :expired, organization: client_org, invited_by: invited_by)
      expect(invitation.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      invitation = build(:invitation, organization: client_org, invited_by: invited_by)
      expect(invitation.expired?).to be false
    end
  end
end
