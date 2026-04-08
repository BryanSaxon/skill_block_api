class TrainingAssignmentsController < ApplicationController
  before_action :set_training_assignment, only: %i[show update destroy]

  def index
    authorize TrainingAssignment
    assignments = policy_scope(TrainingAssignment)
      .includes(:curriculum, :organization_machine, :training_progresses)
      .order(created_at: :desc)
    render json: TrainingAssignmentSerializer.new(assignments, include: [:curriculum, :training_progresses]).serializable_hash
  end

  def show
    authorize @training_assignment
    render json: TrainingAssignmentSerializer.new(
      @training_assignment,
      include: [:curriculum, :training_progresses]
    ).serializable_hash
  end

  def create
    assignment = TrainingAssignment.new(assignment_params.merge(assigned_by: current_user))
    authorize assignment

    if assignment.save
      render json: TrainingAssignmentSerializer.new(assignment).serializable_hash, status: :created
    else
      render json: {errors: assignment.errors.full_messages}, status: :unprocessable_content
    end
  end

  def update
    authorize @training_assignment

    if @training_assignment.update(update_params)
      render json: TrainingAssignmentSerializer.new(@training_assignment).serializable_hash
    else
      render json: {errors: @training_assignment.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @training_assignment
    @training_assignment.destroy
    head :no_content
  end

  def bulk
    unless current_user.admin_org_user? || current_user.admin? || current_user.manager?
      return render json: {error: "Forbidden"}, status: :forbidden
    end

    user_ids = Array(params[:user_ids])
    curriculum_id = params[:curriculum_id]
    organization_machine_id = params[:organization_machine_id]
    due_date = params[:due_date]

    if user_ids.blank? || curriculum_id.blank? || organization_machine_id.blank?
      return render json: {errors: ["user_ids, curriculum_id, and organization_machine_id are required"]},
        status: :unprocessable_content
    end

    assignments = []
    errors = []

    User.where(id: user_ids).each do |user|
      assignment = TrainingAssignment.new(
        user: user,
        curriculum_id: curriculum_id,
        organization_machine_id: organization_machine_id,
        assigned_by: current_user,
        due_date: due_date,
        status: :not_started
      )
      if assignment.save
        assignments << assignment
      else
        errors << {user_id: user.id, errors: assignment.errors.full_messages}
      end
    end

    render json: {
      created: TrainingAssignmentSerializer.new(assignments).serializable_hash,
      errors: errors
    }, status: :multi_status
  end

  private

  def set_training_assignment
    @training_assignment = TrainingAssignment.find(params[:id])
  end

  def assignment_params
    params.permit(:user_id, :curriculum_id, :organization_machine_id, :due_date, :status)
  end

  def update_params
    params.permit(:due_date, :status)
  end
end
