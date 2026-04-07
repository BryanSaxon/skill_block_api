class TrainingAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :curriculum
  belongs_to :organization_machine
  belongs_to :assigned_by, class_name: "User"
  has_many :training_progresses, dependent: :destroy

  enum :status, {
    not_started: "not_started",
    in_progress: "in_progress",
    completed: "completed"
  }, validate: true

  validates :status, presence: true

  scope :overdue, -> { where("due_date < ? AND status != ?", Date.current, "completed") }
  scope :due_within, ->(days) {
    where("due_date BETWEEN ? AND ? AND status != ?", Date.current, days.days.from_now.to_date, "completed")
  }

  # Priority order for "Next Up" display:
  # overdue → in_progress → due_within_7_days → not_started
  def priority_rank
    return 0 if due_date&.past? && !completed?
    return 1 if in_progress?
    return 2 if due_date&.between?(Date.current, 7.days.from_now.to_date) && not_started?
    3
  end
end
