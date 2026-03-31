require "rails_helper"

RSpec.describe "UserOrganizationMachines", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:owner) { create(:owner_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:org_machine) { create(:organization_machine, organization: other_org) }

  let(:base_path) { "/organizations/#{other_org.id}/organization_machines/#{org_machine.id}/user_organization_machines" }

  describe "GET /organizations/:id/organization_machines/:id/user_organization_machines" do
    let!(:uom) { create(:user_organization_machine, organization_machine: org_machine) }

    it "returns 401 without a token" do
      get base_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns assignments for admin" do
      get base_path, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end

    it "returns 403 for operator" do
      get base_path, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /organizations/:id/organization_machines/:id/user_organization_machines" do
    it "returns 401 without a token" do
      post base_path, params: {user_id: operator.id}
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows admin to assign an operator" do
      post base_path, params: {user_id: operator.id}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
    end

    it "returns 403 for manager" do
      post base_path, params: {user_id: operator.id}, headers: auth_headers_for(manager)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 when assigning the same operator twice" do
      create(:user_organization_machine, user: operator, organization_machine: org_machine)
      post base_path, params: {user_id: operator.id}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/organization_machines/:id/user_organization_machines/:id" do
    let!(:uom) { create(:user_organization_machine, user: operator, organization_machine: org_machine) }

    it "allows admin to remove an assignment" do
      delete "#{base_path}/#{uom.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for manager" do
      delete "#{base_path}/#{uom.id}", headers: auth_headers_for(manager)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
