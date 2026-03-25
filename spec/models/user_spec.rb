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

  describe "super_admin restriction" do
    it "allows super_admin in the Skill Block org" do
      user = build(:super_admin_user, organization: skill_block_org)
      expect(user).to be_valid
    end

    it "disallows super_admin in another org" do
      user = build(:user, role: :super_admin, organization: other_org)
      expect(user).not_to be_valid
      expect(user.errors[:role]).to be_present
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
