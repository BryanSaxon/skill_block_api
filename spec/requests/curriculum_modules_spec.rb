require "rails_helper"

RSpec.describe "CurriculumModules (training progress)", type: :request do
  let(:org) { create(:organization) }
  let(:admin) { create(:admin_user, organization: org) }
  let(:operator) { create(:user, organization: org) }

  let(:machine) { create(:organization_machine, organization: org) }
  let(:curriculum) { create(:curriculum, organization: org, organization_machine: machine) }
  let!(:content_mod) { create(:curriculum_module, curriculum: curriculum, position: 1) }
  let!(:assignment) { create(:training_assignment, user: operator, curriculum: curriculum, organization_machine: machine, assigned_by: admin) }

  let(:base_path) { "/training_assignments/#{assignment.id}/modules/#{content_mod.id}" }

  describe "POST .../start" do
    it "returns 401 without a token" do
      post "#{base_path}/start"
      expect(response).to have_http_status(:unauthorized)
    end

    it "starts a module for the assigned operator" do
      post "#{base_path}/start", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:status]).to eq("in_progress")
    end

    it "transitions assignment to in_progress" do
      post "#{base_path}/start", headers: auth_headers_for(operator)
      expect(assignment.reload.status).to eq("in_progress")
    end

    it "returns error if module already started" do
      create(:training_progress, training_assignment: assignment, curriculum_module: content_mod, status: :in_progress)
      post "#{base_path}/start", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 403 for another operator's assignment" do
      other_op = create(:user, organization: org)
      post "#{base_path}/start", headers: auth_headers_for(other_op)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST .../complete (content module)" do
    before do
      create(:training_progress, training_assignment: assignment, curriculum_module: content_mod, status: :in_progress)
    end

    it "completes a content module" do
      post "#{base_path}/complete", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:status]).to eq("completed")
    end

    it "marks assignment complete when all modules done" do
      post "#{base_path}/complete", headers: auth_headers_for(operator)
      expect(assignment.reload.status).to eq("completed")
    end
  end

  describe "POST .../submit_answer (quiz module)" do
    let!(:quiz_mod) { create(:quiz_module, curriculum: curriculum, position: 2) }
    let(:quiz_path) { "/training_assignments/#{assignment.id}/modules/#{quiz_mod.id}" }

    before do
      create(:training_progress, training_assignment: assignment, curriculum_module: quiz_mod, status: :in_progress)
    end

    it "records a correct answer" do
      post "#{quiz_path}/submit_answer",
        params: {question_id: "q1", answer: "4"},
        headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:correct]).to be true
      expect(json[:explanation]).to be_present
    end

    it "records an incorrect answer" do
      post "#{quiz_path}/submit_answer",
        params: {question_id: "q1", answer: "3"},
        headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:correct]).to be false
    end

    it "returns 404 for unknown question" do
      post "#{quiz_path}/submit_answer",
        params: {question_id: "unknown", answer: "x"},
        headers: auth_headers_for(operator)
      expect(response).to have_http_status(:not_found)
    end

    it "returns unprocessable without params" do
      post "#{quiz_path}/submit_answer",
        params: {},
        headers: auth_headers_for(operator)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST .../complete (quiz module — pass/fail)" do
    let!(:quiz_mod) { create(:quiz_module, curriculum: curriculum, position: 2) }
    let(:quiz_path) { "/training_assignments/#{assignment.id}/modules/#{quiz_mod.id}" }

    it "rejects completion with insufficient quiz score" do
      # only 1 of 4 correct = 25%
      create(:training_progress, training_assignment: assignment, curriculum_module: quiz_mod, status: :in_progress,
        quiz_answers: {"q1" => "4", "q2" => "red", "q3" => "6", "q4" => "2"})
      post "#{quiz_path}/complete", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:score]).to eq(25)
    end

    it "allows completion with ≥75% quiz score" do
      # 3 of 4 correct = 75%
      create(:training_progress, training_assignment: assignment, curriculum_module: quiz_mod, status: :in_progress,
        quiz_answers: {"q1" => "4", "q2" => "blue", "q3" => "9", "q4" => "2"})
      post "#{quiz_path}/complete", headers: auth_headers_for(operator)
      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:status]).to eq("completed")
    end
  end
end
