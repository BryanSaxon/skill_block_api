class CurriculumModuleSerializer
  include JSONAPI::Serializer

  attributes :title, :position, :module_type, :estimated_minutes, :content, :review_status

  belongs_to :curriculum
end
