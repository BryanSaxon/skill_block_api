class CurriculaController < ApplicationController
  before_action :set_organization
  before_action :set_curriculum, only: %i[show update publish]

  def index
    authorize Curriculum
    curricula = policy_scope(Curriculum)
      .where(organization_id: @organization.id)
      .includes(:organization_machine, :curriculum_modules)
    render json: CurriculumSerializer.new(curricula, include: [:curriculum_modules]).serializable_hash
  end

  def show
    authorize @curriculum
    render json: CurriculumSerializer.new(@curriculum, include: [:curriculum_modules]).serializable_hash
  end

  # POST /curricula/generate
  # Params: organization_machine_id, role_level, document_ids[]
  def generate
    authorize Curriculum, :create?

    org_machine = OrganizationMachine.find(params[:organization_machine_id])
    document_ids = Array(params[:document_ids]).map(&:to_i)
    role_level = params[:role_level].to_s

    unless Curriculum.role_levels.key?(role_level)
      return render json: {errors: ["Invalid role_level"]}, status: :unprocessable_content
    end

    if document_ids.blank?
      return render json: {errors: ["At least one document_id is required"]}, status: :unprocessable_content
    end

    curriculum = Curriculum.create!(
      organization: org_machine.organization,
      organization_machine: org_machine,
      title: "Generating…",
      role_level: role_level,
      status: :generating,
      source_document_ids: document_ids
    )

    GenerateCurriculumJob.perform_later(curriculum.id, document_ids)

    render json: CurriculumSerializer.new(curriculum).serializable_hash, status: :accepted
  end

  # PATCH /curricula/:id
  def update
    authorize @curriculum

    if @curriculum.update(curriculum_params)
      render json: CurriculumSerializer.new(@curriculum, include: [:curriculum_modules]).serializable_hash
    else
      render json: {errors: @curriculum.errors.full_messages}, status: :unprocessable_content
    end
  end

  # POST /curricula/:id/publish
  def publish
    authorize @curriculum, :update?

    modules_visited = @curriculum.curriculum_modules.where.not(review_status: :unreviewed).count
    total_modules = @curriculum.curriculum_modules.count

    if modules_visited < total_modules
      return render json: {
        errors: ["All #{total_modules} modules must be visited before publishing (#{modules_visited} reviewed so far)"]
      }, status: :unprocessable_content
    end

    @curriculum.update!(status: :published)
    render json: CurriculumSerializer.new(@curriculum, include: [:curriculum_modules]).serializable_hash
  end

  # GET /manager/compliance_report
  def compliance_report
    unless current_user.admin_org_user? || current_user.admin? || current_user.manager?
      return render json: {error: "Forbidden"}, status: :forbidden
    end

    org_id = current_user.admin_org_user? ? nil : current_user.organization_id
    operators = org_id ? User.where(organization_id: org_id, role: :operator) : User.where(role: :operator)
    curricula = org_id ? Curriculum.where(organization_id: org_id, status: :published) : Curriculum.published

    matrix = operators.map do |op|
      curricula.map do |curr|
        assignment = TrainingAssignment.find_by(user: op, curriculum: curr)
        {
          operator_id: op.id,
          operator_name: op.full_name,
          curriculum_id: curr.id,
          curriculum_title: curr.title,
          status: assignment&.status || "unassigned"
        }
      end
    end.flatten

    render json: {data: matrix}
  end

  private

  def set_organization
    @organization = if params[:organization_id].present?
      Organization.find(params[:organization_id])
    else
      current_user.organization
    end
  end

  def set_curriculum
    @curriculum = Curriculum.find(params[:id])
  end

  def curriculum_params
    params.permit(:title, :role_level, :status)
  end
end
