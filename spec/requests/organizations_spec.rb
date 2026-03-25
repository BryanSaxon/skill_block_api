require "rails_helper"

RSpec.describe "Organizations", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }

  let(:super_admin) { create(:super_admin_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:employee) { create(:user, organization: other_org) }

  describe "GET /organizations" do
    before {
      skill_block_org
      other_org
    }

    it "returns 401 without a token" do
      get "/organizations"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns all organizations for super_admin" do
      get "/organizations", headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(2)
    end

    it "returns only the user's organization for non-super_admin" do
      get "/organizations", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
      expect(json[:data].first[:id]).to eq(other_org.id.to_s)
    end
  end

  describe "GET /organizations/:id" do
    it "returns 401 without a token" do
      get "/organizations/#{other_org.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the organization for a user in the same org" do
      get "/organizations/#{other_org.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq(other_org.name)
    end

    it "returns 403 when accessing another org" do
      get "/organizations/#{skill_block_org.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 404 for a non-existent organization" do
      get "/organizations/0", headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /organizations" do
    let(:valid_params) { {name: "New Org"} }

    it "returns 401 without a token" do
      post "/organizations", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows super_admin to create an organization" do
      post "/organizations", params: valid_params, headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq("New Org")
    end

    it "returns 403 for admin" do
      post "/organizations", params: valid_params, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      post "/organizations", params: {name: ""}, headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end
  end

  describe "PATCH /organizations/:id" do
    it "returns 401 without a token" do
      patch "/organizations/#{other_org.id}", params: {name: "Updated"}
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows super_admin to update any organization" do
      patch "/organizations/#{other_org.id}", params: {name: "Updated"}, headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq("Updated")
    end

    it "allows admin to update their own organization" do
      patch "/organizations/#{other_org.id}", params: {name: "Updated"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 when admin updates another org" do
      patch "/organizations/#{skill_block_org.id}", params: {name: "Updated"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      patch "/organizations/#{other_org.id}", params: {name: ""}, headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id" do
    it "returns 401 without a token" do
      delete "/organizations/#{other_org.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows super_admin to delete an organization" do
      delete "/organizations/#{other_org.id}", headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:no_content)
      expect(Organization.exists?(other_org.id)).to be false
    end

    it "returns 403 for admin" do
      delete "/organizations/#{other_org.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
