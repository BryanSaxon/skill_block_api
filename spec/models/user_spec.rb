require "rails_helper"

RSpec.describe User, type: :model do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user, organization: other_org) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to have_secure_password }

    it "is invalid with a malformed email" do
      user = build(:user, email: "notanemail", organization: other_org)
      expect(user).not_to be_valid
    end

    it "normalizes email to lowercase" do
      user = create(:user, email: "Test@Example.COM", organization: other_org)
      expect(user.email).to eq("test@example.com")
    end
  end

  describe "role enum" do
    it "defaults to operator" do
      user = create(:user, organization: other_org)
      expect(user.role).to eq("operator")
    end

    it "rejects an invalid role integer" do
      user = build(:user, organization: other_org)
      user.write_attribute(:role, 99)
      expect(user).not_to be_valid
    end
  end

  describe "owner restriction" do
    it "allows owner in the Skill Block org" do
      user = build(:admin_org_user, organization: skill_block_org)
      expect(user).to be_valid
    end

    it "disallows owner in another org" do
      user = build(:user, role: :owner, organization: other_org)
      expect(user).not_to be_valid
      expect(user.errors[:role]).to be_present
    end
  end

  describe "#admin_org_user?" do
    it "returns true for users in the admin org" do
      user = build(:admin_org_user)
      expect(user.admin_org_user?).to be true
    end

    it "returns false for users in client orgs" do
      user = build(:user)
      expect(user.admin_org_user?).to be false
    end
  end

  describe "manager assignment" do
    let(:org) { create(:organization) }
    let(:mgr) { create(:manager_user, organization: org) }

    it "is valid when an operator is assigned a manager in the same org" do
      operator = build(:user, role: :operator, organization: org, manager: mgr)
      expect(operator).to be_valid
    end

    it "is invalid when manager is in a different org" do
      other_mgr = create(:manager_user)
      operator = build(:user, role: :operator, organization: org, manager: other_mgr)
      expect(operator).not_to be_valid
    end

    it "is invalid when a non-operator is assigned a manager" do
      admin = build(:admin_user, organization: org, manager: mgr)
      expect(admin).not_to be_valid
    end

    it "is invalid when the manager does not have manager role" do
      non_mgr = create(:admin_user, organization: org)
      operator = build(:user, role: :operator, organization: org, manager: non_mgr)
      expect(operator).not_to be_valid
    end
  end

  describe "#generates_token_for :password_reset" do
    it "generates a password reset token" do
      user = create(:user, organization: other_org)
      token = user.generate_token_for(:password_reset)
      expect(token).to be_present
    end

    it "can find the user by token" do
      user = create(:user, organization: other_org)
      token = user.generate_token_for(:password_reset)
      expect(User.find_by_password_reset_token(token)).to eq(user)
    end

    it "invalidates token after password change" do
      user = create(:user, organization: other_org)
      token = user.generate_token_for(:password_reset)
      user.update!(password: "newpassword123", password_confirmation: "newpassword123")
      expect(User.find_by_password_reset_token(token)).to be_nil
    end
  end
end
