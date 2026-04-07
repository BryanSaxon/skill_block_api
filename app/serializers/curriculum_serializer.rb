class CurriculumSerializer
  include JSONAPI::Serializer

  attributes :title, :role_level, :status, :source_document_ids, :generated_at

  belongs_to :organization
  belongs_to :organization_machine
  has_many :curriculum_modules
end
