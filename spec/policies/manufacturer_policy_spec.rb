require "rails_helper"

RSpec.describe ManufacturerPolicy, type: :policy do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:manufacturer) { create(:manufacturer) }

  subject { described_class }

  permissions :index?, :show? do
    it "grants access to all roles" do
      expect(subject).to permit(admin_org_user, manufacturer)
      expect(subject).to permit(admin, manufacturer)
      expect(subject).to permit(operator, manufacturer)
    end
  end

  permissions :create?, :update?, :destroy? do
    it "grants access to admin org user" do
      expect(subject).to permit(admin_org_user, manufacturer)
    end

    it "denies access to admin" do
      expect(subject).not_to permit(admin, manufacturer)
    end

    it "denies access to operator" do
      expect(subject).not_to permit(operator, manufacturer)
    end
  end

  describe ManufacturerPolicy::Scope do
    it "returns all manufacturers for any user" do
      manufacturer
      scope = described_class.new(admin, Manufacturer).resolve
      expect(scope).to include(manufacturer)
    end
  end
end
