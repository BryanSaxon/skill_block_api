require "rails_helper"

RSpec.describe "Registrations", type: :request do
  let(:organization) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user) }
  let(:invitation) { create(:invitation, organization: organization, invited_by: admin_org_user) }

  let(:valid_registration_params) do
    {
      first_name: "Jane",
      last_name: "Doe",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  describe "GET /registrations/:token" do
    it "returns 200 with email, organization_name, and role for a valid pending token" do
      get "/registrations/#{invitation.token}"
      expect(response).to have_http_status(:ok)
      expect(json[:email]).to eq(invitation.email)
      expect(json[:organization_name]).to eq(organization.name)
      expect(json[:role]).to eq(invitation.role)
    end

    it "returns 422 for an expired token" do
      expired = create(:invitation, :expired, organization: organization, invited_by: admin_org_user)
      get "/registrations/#{expired.token}"
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:error]).to be_present
    end

    it "returns 422 for an already accepted token" do
      accepted = create(:invitation, :accepted, organization: organization, invited_by: admin_org_user)
      get "/registrations/#{accepted.token}"
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:error]).to be_present
    end

    it "returns 422 for an invalid or nonexistent token" do
      get "/registrations/nonexistent_token_abc"
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:error]).to be_present
    end
  end

  describe "POST /registrations/:token" do
    it "returns 201 and creates a user with the correct role and organization" do
      post "/registrations/#{invitation.token}", params: valid_registration_params
      expect(response).to have_http_status(:created)
      created_user = User.find_by(email: invitation.email)
      expect(created_user).to be_present
      expect(created_user.role).to eq(invitation.role)
      expect(created_user.organization_id).to eq(organization.id)
    end

    it "returns a JWT token and user data on success" do
      post "/registrations/#{invitation.token}", params: valid_registration_params
      expect(response).to have_http_status(:created)
      expect(json[:token]).to be_present
      expect(json[:user]).to be_present
    end

    it "marks the invitation as accepted" do
      post "/registrations/#{invitation.token}", params: valid_registration_params
      expect(invitation.reload.accepted_at).to be_present
    end

    it "returns 422 when required fields are missing" do
      post "/registrations/#{invitation.token}", params: {first_name: "Jane"}
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end

    it "returns 422 when password confirmation does not match" do
      post "/registrations/#{invitation.token}",
        params: valid_registration_params.merge(password_confirmation: "wrong")
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end

    it "returns 422 for an expired token" do
      expired = create(:invitation, :expired, organization: organization, invited_by: admin_org_user)
      post "/registrations/#{expired.token}", params: valid_registration_params
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:error]).to be_present
    end

    it "returns 422 for an already accepted token" do
      accepted = create(:invitation, :accepted, organization: organization, invited_by: admin_org_user)
      post "/registrations/#{accepted.token}", params: valid_registration_params
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:error]).to be_present
    end

    it "returns 422 for an invalid or nonexistent token" do
      post "/registrations/nonexistent_token_abc", params: valid_registration_params
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:error]).to be_present
    end

    it "does not create a user when the token is invalid" do
      expect {
        post "/registrations/nonexistent_token_abc", params: valid_registration_params
      }.not_to change(User, :count)
    end
  end
end
