require "rails_helper"

RSpec.describe "Invitations", type: :request do
  let(:skill_block_org) { create(:skill_block_organization) }
  let(:other_org) { create(:organization) }
  let(:another_org) { create(:organization) }

  let(:admin_org_user) { create(:admin_org_user, organization: skill_block_org) }
  let(:client_admin) { create(:admin_user, organization: other_org) }
  let(:manager) { create(:manager_user, organization: other_org) }
  let(:operator) { create(:user, organization: other_org) }
  let(:other_org_admin) { create(:admin_user, organization: another_org) }

  let(:valid_params) { {email: "newperson@example.com", role: "operator"} }

  describe "GET /organizations/:organization_id/invitations" do
    let!(:own_invitation) { create(:invitation, organization: other_org, invited_by: admin_org_user) }
    let!(:other_invitation) { create(:invitation, organization: another_org, invited_by: admin_org_user) }

    it "returns 401 without a token" do
      get "/organizations/#{other_org.id}/invitations"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns invitations scoped to the given organization for admin org user" do
      get "/organizations/#{other_org.id}/invitations", headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:ok)
      ids = json[:data].map { |i| i[:id] }
      expect(ids).to include(own_invitation.id.to_s)
      expect(ids).not_to include(other_invitation.id.to_s)
    end

    it "returns invitations for client admin in own org" do
      get "/organizations/#{other_org.id}/invitations", headers: auth_headers_for(client_admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].map { |i| i[:id] }).to include(own_invitation.id.to_s)
    end
  end

  describe "POST /organizations/:organization_id/invitations" do
    it "returns 401 without a token" do
      post "/organizations/#{other_org.id}/invitations", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 201 for admin org user creating an invitation for any org" do
      post "/organizations/#{other_org.id}/invitations",
        params: valid_params,
        headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:email]).to eq("newperson@example.com")
    end

    it "returns 201 for client admin creating an invitation for their own org" do
      post "/organizations/#{other_org.id}/invitations",
        params: valid_params,
        headers: auth_headers_for(client_admin)
      expect(response).to have_http_status(:created)
      expect(json[:data][:attributes][:role]).to eq("operator")
    end

    it "returns 403 for client admin creating an invitation for a different org" do
      post "/organizations/#{another_org.id}/invitations",
        params: valid_params,
        headers: auth_headers_for(client_admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 403 for manager" do
      post "/organizations/#{other_org.id}/invitations",
        params: valid_params,
        headers: auth_headers_for(manager)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 403 for operator" do
      post "/organizations/#{other_org.id}/invitations",
        params: valid_params,
        headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 with an invalid email" do
      post "/organizations/#{other_org.id}/invitations",
        params: {email: "not-valid", role: "operator"},
        headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end

    it "returns 422 when a user with that email already exists" do
      existing_user = create(:user, organization: other_org)
      post "/organizations/#{other_org.id}/invitations",
        params: {email: existing_user.email, role: "operator"},
        headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end

    it "sends an invitation email on success" do
      expect {
        post "/organizations/#{other_org.id}/invitations",
          params: valid_params,
          headers: auth_headers_for(admin_org_user)
      }.to have_enqueued_mail(InvitationsMailer, :invite)
    end
  end

  describe "DELETE /organizations/:organization_id/invitations/:id" do
    let!(:invitation) { create(:invitation, organization: other_org, invited_by: admin_org_user) }
    let!(:another_org_invitation) { create(:invitation, organization: another_org, invited_by: admin_org_user) }

    it "returns 401 without a token" do
      delete "/organizations/#{other_org.id}/invitations/#{invitation.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 204 for admin org user" do
      delete "/organizations/#{other_org.id}/invitations/#{invitation.id}",
        headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:no_content)
      expect(Invitation.exists?(invitation.id)).to be false
    end

    it "returns 204 for client admin deleting an invitation from their own org" do
      delete "/organizations/#{other_org.id}/invitations/#{invitation.id}",
        headers: auth_headers_for(client_admin)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for client admin deleting an invitation from a different org" do
      delete "/organizations/#{another_org.id}/invitations/#{another_org_invitation.id}",
        headers: auth_headers_for(client_admin)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 403 for manager" do
      delete "/organizations/#{other_org.id}/invitations/#{invitation.id}",
        headers: auth_headers_for(manager)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
