class CurriculumModulesController < ApplicationController
  before_action :set_training_assignment
  before_action :set_module

  # POST /training_assignments/:training_assignment_id/modules/:id/start
  def start
    progress = find_or_initialize_progress

    unless progress.not_started?
      return render json: {error: "Module already #{progress.status}"}, status: :unprocessable_content
    end

    progress.in_progress!
    update_assignment_status_if_needed
    render json: TrainingProgressSerializer.new(progress).serializable_hash
  end

  # POST /training_assignments/:training_assignment_id/modules/:id/submit_answer
  def submit_answer
    progress = find_or_initialize_progress

    question_id = params[:question_id].to_s
    answer = params[:answer].to_s

    if question_id.blank? || answer.blank?
      return render json: {errors: ["question_id and answer are required"]}, status: :unprocessable_content
    end

    questions = Array(@module.content["questions"])
    question = questions.find { |q| q["id"].to_s == question_id }

    unless question
      return render json: {error: "Question not found"}, status: :not_found
    end

    correct = question["correct_answer"].to_s == answer
    updated_answers = (progress.quiz_answers || {}).merge(question_id => answer)
    progress.update!(quiz_answers: updated_answers)

    render json: {
      correct: correct,
      explanation: question["explanation"],
      progress: TrainingProgressSerializer.new(progress).serializable_hash
    }
  end

  # POST /training_assignments/:training_assignment_id/modules/:id/complete
  def complete
    progress = find_or_initialize_progress

    if progress.completed?
      return render json: {error: "Module already completed"}, status: :unprocessable_content
    end

    if @module.quiz?
      score = quiz_score(progress)
      if score < 0.75
        return render json: {
          error: "Quiz score too low to complete",
          score: (score * 100).round,
          required: 75
        }, status: :unprocessable_content
      end
    end

    progress.update!(status: :completed, completed_at: Time.current)
    maybe_complete_assignment
    render json: TrainingProgressSerializer.new(progress).serializable_hash
  end

  private

  def set_training_assignment
    @training_assignment = TrainingAssignment.find(params[:training_assignment_id])
    authorize @training_assignment, :show?
  end

  def set_module
    @module = @training_assignment.curriculum.curriculum_modules.find(params[:id])
  end

  def find_or_initialize_progress
    TrainingProgress.find_or_initialize_by(
      training_assignment: @training_assignment,
      curriculum_module: @module
    ) do |p|
      p.status = :not_started
    end
  end

  def update_assignment_status_if_needed
    @training_assignment.in_progress! if @training_assignment.not_started?
  end

  def quiz_score(progress)
    questions = Array(@module.content["questions"])
    return 1.0 if questions.empty?
    answers = progress.quiz_answers || {}
    correct_count = questions.count { |q| q["correct_answer"].to_s == answers[q["id"].to_s].to_s }
    correct_count.to_f / questions.size
  end

  def maybe_complete_assignment
    all_modules = @training_assignment.curriculum.curriculum_modules
    completed_ids = @training_assignment.training_progresses.where(status: :completed).pluck(:curriculum_module_id)
    if all_modules.pluck(:id).sort == completed_ids.sort
      @training_assignment.update_column(:status, "completed")
    end
  end
end
