class TelemetryReading < ApplicationRecord
  belongs_to :organization_machine

  validates :parameter_name, presence: true
  validates :value, presence: true
  validates :recorded_at, presence: true

  scope :for_parameter, ->(name) { where(parameter_name: name) }
  scope :recent_first, -> { order(recorded_at: :desc) }
end
