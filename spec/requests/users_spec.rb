require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:third_org) { create(:organization) }

  let(:super_admin) { create(:super_admin_user, organization: skill_block_org) }
  let(:admin) { create(:admin_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:other_org_user) { create(:user, organization: third_org) }

  describe "GET /users" do
    before {
      super_admin
      admin
      operator
      other_org_user
    }

    it "returns 401 without a token" do
      get "/users"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns all users for super_admin" do
      get "/users", headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(4)
    end

    it "returns only users in the same org for admin" do
      get "/users", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      ids = json[:data].map { |u| u[:id] }
      expect(ids).to include(admin.id.to_s, operator.id.to_s)
      expect(ids).not_to include(other_org_user.id.to_s)
    end

    it "returns 403 for operator" do
      get "/users", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /users/:id" do
    it "returns 401 without a token" do
      get "/users/#{operator.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a user to view themselves" do
      get "/users/#{operator.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:email]).to eq(operator.email)
    end

    it "allows admin to view a user in their org" do
      get "/users/#{operator.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 when viewing a user in a different org" do
      get "/users/#{other_org_user.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    it "does not expose password_digest" do
      get "/users/#{operator.id}", headers: auth_headers_for(operator)
      expect(json[:data][:attributes].keys).not_to include(:password_digest)
    end

    it "returns 404 for a non-existent user" do
      get "/users/0", headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        organization_id: other_org.id,
        first_name: "New",
        last_name: "User",
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    it "returns 401 without a token" do
      post "/users", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows admin to create a user" do
      post "/users", params: valid_params, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:email]).to eq("new@example.com")
    end

    it "allows super_admin to create a user" do
      post "/users", params: valid_params, headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:created)
    end

    it "returns 403 for operator" do
      post "/users", params: valid_params, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      post "/users", params: valid_params.merge(email: ""), headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end

    it "returns 404 for a non-existent organization" do
      post "/users", params: valid_params.merge(organization_id: 0), headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /users/:id" do
    it "returns 401 without a token" do
      patch "/users/#{operator.id}", params: {first_name: "Updated"}
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a user to update themselves" do
      patch "/users/#{operator.id}", params: {first_name: "Updated"}, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:first_name]).to eq("Updated")
    end

    it "allows admin to update a user in their org" do
      patch "/users/#{operator.id}", params: {first_name: "Updated"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 when updating a user in a different org" do
      patch "/users/#{other_org_user.id}", params: {first_name: "Updated"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with invalid params" do
      patch "/users/#{operator.id}", params: {email: "invalid"}, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /users/:id" do
    it "returns 401 without a token" do
      delete "/users/#{operator.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows admin to delete a user in their org" do
      delete "/users/#{operator.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:no_content)
      expect(User.exists?(operator.id)).to be false
    end

    it "returns 403 when admin tries to delete themselves" do
      delete "/users/#{admin.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 403 when deleting a user in a different org" do
      delete "/users/#{other_org_user.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "allows super_admin to delete any user" do
      delete "/users/#{other_org_user.id}", headers: auth_headers_for(super_admin)
      expect(response).to have_http_status(:no_content)
    end
  end
end
