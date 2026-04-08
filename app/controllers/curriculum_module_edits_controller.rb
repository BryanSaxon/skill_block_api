# Handles inline edits to curriculum modules from the admin curriculum editor.
# Separate from the training flow controller (curriculum_modules_controller.rb).
class CurriculumModuleEditsController < ApplicationController
  before_action :set_curriculum
  before_action :set_module

  # PATCH /curricula/:curriculum_id/modules/:id
  def update
    authorize @curriculum, :update?

    if @module.update(module_params)
      render json: CurriculumModuleSerializer.new(@module).serializable_hash
    else
      render json: {errors: @module.errors.full_messages}, status: :unprocessable_content
    end
  end

  private

  def set_curriculum
    @curriculum = Curriculum.find(params[:curriculum_id])
  end

  def set_module
    @module = @curriculum.curriculum_modules.find(params[:id])
  end

  def module_params
    params.permit(:title, :estimated_minutes, :review_status, content: {})
  end
end
