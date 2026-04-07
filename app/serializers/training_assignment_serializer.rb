class TrainingAssignmentSerializer
  include JSONAPI::Serializer

  attributes :status, :due_date, :created_at

  belongs_to :user
  belongs_to :curriculum
  belongs_to :organization_machine
  belongs_to :assigned_by, serializer: UserSerializer, record_type: :user
  has_many :training_progresses
end
