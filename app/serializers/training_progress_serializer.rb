class TrainingProgressSerializer
  include JSONAPI::Serializer

  attributes :status, :quiz_answers, :completed_at

  belongs_to :training_assignment
  belongs_to :curriculum_module
end
