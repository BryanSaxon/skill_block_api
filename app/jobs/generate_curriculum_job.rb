class GenerateCurriculumJob < ApplicationJob
  queue_as :default

  def perform(curriculum_id, document_ids)
    curriculum = Curriculum.find(curriculum_id)
    return unless curriculum.generating?

    result = CurriculumGenerator.generate(curriculum: curriculum, document_ids: document_ids)

    Curriculum.transaction do
      curriculum.curriculum_modules.destroy_all

      result["modules"].each_with_index do |mod_data, idx|
        curriculum.curriculum_modules.create!(
          title: mod_data["title"],
          position: idx + 1,
          module_type: mod_data["module_type"],
          estimated_minutes: mod_data["estimated_minutes"],
          content: mod_data["content"] || {},
          review_status: :unreviewed
        )
      end

      curriculum.update!(
        title: result["title"],
        status: :draft,
        generated_at: Time.current,
        source_document_ids: document_ids
      )
    end
  rescue => e
    Rails.logger.error("GenerateCurriculumJob failed for #{curriculum_id}: #{e.message}")
    Curriculum.find_by(id: curriculum_id)&.update(status: :draft)
  end
end
