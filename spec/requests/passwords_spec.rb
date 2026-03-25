require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:org) { create(:organization) }
  let(:user) { create(:user, organization: org, email: "reset@example.com") }

  describe "POST /passwords" do
    it "returns 200 for a known email" do
      post "/passwords", params: {email: user.email}
      expect(response).to have_http_status(:ok)
      expect(json[:message]).to be_present
    end

    it "returns 200 for an unknown email (enumeration prevention)" do
      post "/passwords", params: {email: "nobody@example.com"}
      expect(response).to have_http_status(:ok)
    end

    it "includes reset_token in development" do
      post "/passwords", params: {email: user.email}
      expect(json[:reset_token]).to be_present
    end
  end

  describe "PATCH /passwords/:token" do
    let(:token) { user.generate_token_for(:password_reset) }

    it "resets the password with a valid token" do
      patch "/passwords/#{token}", params: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
      expect(response).to have_http_status(:ok)
      expect(json[:message]).to be_present
    end

    it "invalidates all sessions after reset" do
      user.sessions.create!(ip_address: "127.0.0.1", user_agent: "test")
      patch "/passwords/#{token}", params: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
      expect(user.sessions.count).to eq(0)
    end

    it "returns 422 for a mismatched confirmation" do
      patch "/passwords/#{token}", params: {
        password: "newpassword123",
        password_confirmation: "different"
      }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 422 for an invalid token" do
      patch "/passwords/badtoken", params: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
