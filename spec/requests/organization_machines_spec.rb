require "rails_helper"

RSpec.describe "OrganizationMachines", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:machine) { create(:machine) }

  let(:base_path) { "/organizations/#{other_org.id}/organization_machines" }

  describe "GET /organizations/:id/organization_machines" do
    let!(:org_machine) { create(:organization_machine, organization: other_org, machine: machine) }

    it "returns 401 without a token" do
      get base_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns organization machines for admin" do
      get base_path, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end

    it "returns organization machines for manager" do
      get base_path, headers: auth_headers_for(manager)
      expect(response).to have_http_status(:ok)
    end

    it "returns organization machines for operator in same org" do
      get base_path, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /organizations/:id/organization_machines/:id" do
    let(:org_machine) { create(:organization_machine, organization: other_org) }

    it "returns the organization machine for admin" do
      get "#{base_path}/#{org_machine.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:vin]).to eq(org_machine.vin)
    end

    it "returns the machine for an assigned operator" do
      create(:user_organization_machine, user: operator, organization_machine: org_machine)
      get "#{base_path}/#{org_machine.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 for an unassigned operator" do
      get "#{base_path}/#{org_machine.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /organizations/:id/organization_machines" do
    let(:valid_params) { {machine_id: machine.id, vin: "VIN-001"} }

    it "returns 401 without a token" do
      post base_path, params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows admin to create an organization machine" do
      post base_path, params: valid_params, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:vin]).to eq("VIN-001")
      expect(json[:data][:attributes][:status]).to eq("active")
    end

    it "allows admin org user to create an organization machine" do
      post base_path, params: valid_params, headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:created)
    end

    it "returns 403 for manager" do
      post base_path, params: valid_params, headers: auth_headers_for(manager)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      post base_path, params: {machine_id: machine.id, vin: ""}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /organizations/:id/organization_machines/:id" do
    let(:org_machine) { create(:organization_machine, organization: other_org) }

    it "allows admin to update nickname" do
      patch "#{base_path}/#{org_machine.id}", params: {nickname: "Line 3"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:nickname]).to eq("Line 3")
    end

    it "allows manager to update nickname" do
      patch "#{base_path}/#{org_machine.id}", params: {nickname: "Line 3"}, headers: auth_headers_for(manager)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 for operator" do
      patch "#{base_path}/#{org_machine.id}", params: {nickname: "Line 3"}, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    context "state transitions via event param" do
      it "transitions from active to inactive" do
        patch "#{base_path}/#{org_machine.id}", params: {event: "deactivate"}, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(json[:data][:attributes][:status]).to eq("inactive")
      end

      it "returns 422 for an invalid transition" do
        patch "#{base_path}/#{org_machine.id}", params: {event: "complete_maintenance"}, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns 422 for an unknown event" do
        patch "#{base_path}/#{org_machine.id}", params: {event: "explode"}, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /organizations/:id/organization_machines/:id" do
    let(:org_machine) { create(:organization_machine, organization: other_org) }

    it "allows admin to delete an organization machine" do
      delete "#{base_path}/#{org_machine.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for manager" do
      delete "#{base_path}/#{org_machine.id}", headers: auth_headers_for(manager)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
