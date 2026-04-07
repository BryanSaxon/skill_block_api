class TrainingProgress < ApplicationRecord
  belongs_to :training_assignment
  belongs_to :curriculum_module

  enum :status, {
    not_started: "not_started",
    in_progress: "in_progress",
    completed: "completed"
  }, validate: true

  validates :status, presence: true
end
