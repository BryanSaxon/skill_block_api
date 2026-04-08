require "rails_helper"

RSpec.describe "Curricula", type: :request do
  let(:org) { create(:organization) }
  let(:admin) { create(:admin_user, organization: org) }
  let(:manager) { create(:manager_user, organization: org) }
  let(:operator) { create(:user, organization: org) }
  let(:admin_org_user) { create(:admin_org_user) }

  let(:machine) { create(:organization_machine, organization: org) }
  let!(:curriculum) { create(:curriculum, organization: org, organization_machine: machine) }
  let!(:mod) { create(:curriculum_module, curriculum: curriculum) }

  describe "GET /curricula" do
    it "returns 401 without a token" do
      get "/curricula"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns curricula for admin" do
      get "/curricula", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end

    it "returns assigned published curricula for operator" do
      create(:training_assignment, user: operator, curriculum: curriculum, organization_machine: machine, assigned_by: admin)
      get "/curricula", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end

    it "returns empty for operator without assignments" do
      get "/curricula", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(0)
    end
  end

  describe "GET /curricula/:id" do
    it "returns 401 without a token" do
      get "/curricula/#{curriculum.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns curriculum with modules for admin" do
      get "/curricula/#{curriculum.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:id]).to eq(curriculum.id.to_s)
    end

    it "returns 403 for operator without assignment" do
      get "/curricula/#{curriculum.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns curriculum for operator with active assignment" do
      create(:training_assignment, user: operator, curriculum: curriculum, organization_machine: machine, assigned_by: admin)
      get "/curricula/#{curriculum.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
    end
  end
end
