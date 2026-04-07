require "rails_helper"

RSpec.describe "Machines", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:manufacturer) { create(:manufacturer) }

  describe "GET /machines" do
    let!(:machine) { create(:machine, manufacturer: manufacturer) }

    it "returns 401 without a token" do
      get "/machines"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns all machines" do
      get "/machines", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end
  end

  describe "GET /machines/:id" do
    let(:machine) { create(:machine) }

    it "returns the machine" do
      get "/machines/#{machine.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq(machine.name)
    end

    it "returns 404 for a non-existent machine" do
      get "/machines/0", headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /machines" do
    let(:valid_params) { {manufacturer_id: manufacturer.id, name: "Conveyor X", model_number: "CX-100"} }

    it "returns 401 without a token" do
      post "/machines", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows admin org user to create a machine" do
      post "/machines", params: valid_params, headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq("Conveyor X")
    end

    it "returns 403 for admin" do
      post "/machines", params: valid_params, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      post "/machines", params: {manufacturer_id: manufacturer.id, name: ""}, headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /machines/:id" do
    let(:machine) { create(:machine) }

    it "allows admin org user to update a machine" do
      patch "/machines/#{machine.id}", params: {name: "Updated"}, headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq("Updated")
    end

    it "returns 403 for admin" do
      patch "/machines/#{machine.id}", params: {name: "Updated"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /machines/:id" do
    let(:machine) { create(:machine) }

    it "allows admin org user to delete a machine" do
      delete "/machines/#{machine.id}", headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for admin" do
      delete "/machines/#{machine.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
