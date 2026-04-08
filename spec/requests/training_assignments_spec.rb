require "rails_helper"

RSpec.describe "TrainingAssignments", type: :request do
  let(:org) { create(:organization) }
  let(:admin) { create(:admin_user, organization: org) }
  let(:manager) { create(:manager_user, organization: org) }
  let(:operator) { create(:user, organization: org) }
  let(:admin_org_user) { create(:admin_org_user) }

  let(:machine) { create(:organization_machine, organization: org) }
  let(:curriculum) { create(:curriculum, organization: org, organization_machine: machine) }
  let!(:assignment) { create(:training_assignment, user: operator, curriculum: curriculum, organization_machine: machine, assigned_by: admin) }

  describe "GET /training_assignments" do
    it "returns 401 without a token" do
      get "/training_assignments"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns operator's own assignments" do
      get "/training_assignments", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end

    it "returns all org assignments for admin" do
      get "/training_assignments", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(json[:data].length).to eq(1)
    end

    it "returns all assignments for admin org user" do
      get "/training_assignments", headers: auth_headers_for(admin_org_user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /training_assignments/:id" do
    it "returns 401 without a token" do
      get "/training_assignments/#{assignment.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the assignment for the assigned operator" do
      get "/training_assignments/#{assignment.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:id]).to eq(assignment.id.to_s)
    end

    it "returns the assignment for an org admin" do
      get "/training_assignments/#{assignment.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 for operator from another org" do
      other_operator = create(:user, organization: create(:organization))
      get "/training_assignments/#{assignment.id}", headers: auth_headers_for(other_operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /training_assignments" do
    let(:params) do
      {
        user_id: operator.id,
        curriculum_id: curriculum.id,
        organization_machine_id: machine.id,
        due_date: 30.days.from_now.to_date.iso8601
      }
    end

    it "returns 401 without a token" do
      post "/training_assignments", params: params
      expect(response).to have_http_status(:unauthorized)
    end

    it "creates an assignment as admin" do
      new_operator = create(:user, organization: org)
      post "/training_assignments",
        params: params.merge(user_id: new_operator.id),
        headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
    end

    it "creates an assignment as manager" do
      new_operator = create(:user, organization: org)
      post "/training_assignments",
        params: params.merge(user_id: new_operator.id),
        headers: auth_headers_for(manager)
      expect(response).to have_http_status(:created)
    end

    it "returns 403 for operator" do
      post "/training_assignments", params: params, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /training_assignments/:id" do
    it "updates due_date as admin" do
      patch "/training_assignments/#{assignment.id}",
        params: {due_date: 60.days.from_now.to_date.iso8601},
        headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
    end

    it "returns 403 for operator" do
      patch "/training_assignments/#{assignment.id}",
        params: {status: "in_progress"},
        headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /training_assignments/:id" do
    it "deletes assignment as admin" do
      delete "/training_assignments/#{assignment.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 for operator" do
      delete "/training_assignments/#{assignment.id}", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /training_assignments/bulk" do
    let(:op2) { create(:user, organization: org) }
    let(:params) do
      {
        user_ids: [operator.id, op2.id],
        curriculum_id: curriculum.id,
        organization_machine_id: machine.id,
        due_date: 30.days.from_now.to_date.iso8601
      }
    end

    it "returns 401 without a token" do
      post "/training_assignments/bulk", params: params
      expect(response).to have_http_status(:unauthorized)
    end

    it "bulk creates assignments as admin" do
      # operator already has this curriculum, op2 does not
      post "/training_assignments/bulk",
        params: params.merge(user_ids: [op2.id]),
        headers: auth_headers_for(admin)
      expect(response).to have_http_status(:multi_status)
      expect(json[:created][:data].length).to eq(1)
    end

    it "returns 403 for operator" do
      post "/training_assignments/bulk", params: params, headers: auth_headers_for(operator)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns unprocessable for missing params" do
      post "/training_assignments/bulk",
        params: {user_ids: [operator.id]},
        headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
