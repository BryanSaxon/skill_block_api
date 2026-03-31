require "rails_helper"

RSpec.describe "Manufacturers", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:owner) { create(:owner_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }

  describe "GET /manufacturers" do
    let!(:manufacturer) { create(:manufacturer) }

    it "returns 401 without a token" do
      get "/manufacturers"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns all manufacturers" do
      get "/manufacturers", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end
  end

  describe "GET /manufacturers/:id" do
    let(:manufacturer) { create(:manufacturer) }

    it "returns the manufacturer" do
      get "/manufacturers/#{manufacturer.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq(manufacturer.name)
    end

    it "returns 404 for a non-existent manufacturer" do
      get "/manufacturers/0", headers: auth_headers_for(owner)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /manufacturers" do
    it "returns 401 without a token" do
      post "/manufacturers", params: {name: "Acme"}
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows owner to create a manufacturer" do
      post "/manufacturers", params: {name: "Acme"}, headers: auth_headers_for(owner)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:name]).to eq("Acme")
    end

    it "returns 403 for admin" do
      post "/manufacturers", params: {name: "Acme"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      post "/manufacturers", params: {name: ""}, headers: auth_headers_for(owner)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end
  end

  describe "PATCH /manufacturers/:id" do
    let(:manufacturer) { create(:manufacturer) }

    it "allows owner to update a manufacturer" do
      patch "/manufacturers/#{manufacturer.id}", params: {name: "Updated"}, headers: auth_headers_for(owner)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:name]).to eq("Updated")
    end

    it "returns 403 for admin" do
      patch "/manufacturers/#{manufacturer.id}", params: {name: "Updated"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /manufacturers/:id" do
    let(:manufacturer) { create(:manufacturer) }

    it "allows owner to delete a manufacturer" do
      delete "/manufacturers/#{manufacturer.id}", headers: auth_headers_for(owner)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for admin" do
      delete "/manufacturers/#{manufacturer.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
