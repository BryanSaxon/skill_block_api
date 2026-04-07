class Alert < ApplicationRecord
  belongs_to :organization_machine
  belongs_to :resolved_by, class_name: "User", optional: true

  enum :severity, { warning: "warning", critical: "critical" }, validate: true
  enum :status, { active: "active", acknowledged: "acknowledged", resolved: "resolved" }, validate: true

  validates :parameter_name, presence: true
  validates :triggered_value, presence: true
  validates :threshold_value, presence: true
  validates :severity, presence: true
  validates :status, presence: true
  validates :triggered_at, presence: true
  validate :resolved_fields_consistent

  scope :open, -> { where(status: [:active, :acknowledged]) }
  scope :severity_first, -> { order(Arel.sql("CASE severity WHEN 'critical' THEN 0 ELSE 1 END, triggered_at ASC")) }

  private

  def resolved_fields_consistent
    if resolved?
      errors.add(:resolved_at, "must be set when resolved") if resolved_at.blank?
    end
  end
end
