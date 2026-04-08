require "rails_helper"

RSpec.describe "ManagerDashboard", type: :request do
  let(:org) { create(:organization) }
  let(:admin) { create(:admin_user, organization: org) }
  let(:manager) { create(:manager_user, organization: org) }
  let(:operator) { create(:user, organization: org) }
  let(:admin_org_user) { create(:admin_org_user) }

  describe "GET /manager/dashboard" do
    it "returns 401 without a token" do
      get "/manager/dashboard"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns dashboard data for admin" do
      get "/manager/dashboard", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json).to have_key(:overdue_assignments)
      expect(json).to have_key(:unassigned_operators)
      expect(json).to have_key(:machines_with_critical_alerts)
    end

    it "returns dashboard data for manager" do
      get "/manager/dashboard", headers: auth_headers_for(manager)
      expect(response).to have_http_status(:ok)
    end

    it "returns dashboard data for admin org user" do
      get "/manager/dashboard", headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 for operator" do
      get "/manager/dashboard", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    context "with overdue assignments" do
      let(:machine) { create(:organization_machine, organization: org) }
      let(:curriculum) { create(:curriculum, organization: org, organization_machine: machine) }

      it "includes overdue assignments" do
        create(:training_assignment,
          user: operator,
          curriculum: curriculum,
          organization_machine: machine,
          assigned_by: admin,
          due_date: 5.days.ago,
          status: :not_started)

        get "/manager/dashboard", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(json[:overdue_assignments].length).to eq(1)
      end
    end

    context "with unassigned operators" do
      before { operator }  # force creation before the request

      it "includes operators not assigned to any machine" do
        get "/manager/dashboard", headers: auth_headers_for(admin)
        expect(json[:unassigned_operators].any? { |u| u[:id] == operator.id }).to be true
      end
    end
  end
end
