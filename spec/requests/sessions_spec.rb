require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:org) { create(:organization) }
  let(:user) { create(:user, organization: org, email: "login@example.com", password: "password") }

  describe "POST /session" do
    it "returns 201 with a token on valid credentials" do
      post "/session", params: {email: user.email, password: "password"}
      expect(response).to have_http_status(:created)
      expect(json[:token]).to be_present
      expect(json[:user][:data][:attributes][:email]).to eq(user.email)
    end

    it "creates a session record" do
      expect {
        post "/session", params: {email: user.email, password: "password"}
      }.to change(Session, :count).by(1)
    end

    it "returns 401 on invalid password" do
      post "/session", params: {email: user.email, password: "wrong"}
      expect(response).to have_http_status(:unauthorized)
      expect(json[:error]).to be_present
    end

    it "returns 401 for unknown email" do
      post "/session", params: {email: "nobody@example.com", password: "password"}
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /session" do
    it "returns 204 and destroys the session" do
      delete "/session", headers: auth_headers_for(user)
      expect(response).to have_http_status(:no_content)
    end

    it "makes the token unusable after logout" do
      headers = auth_headers_for(user)
      delete "/session", headers: headers
      delete "/session", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 without a token" do
      delete "/session"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
