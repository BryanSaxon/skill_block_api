class OrganizationMachine < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :machine
  has_many :user_organization_machines, dependent: :destroy
  has_many :users, through: :user_organization_machines
  has_many :machine_parameters, dependent: :destroy
  has_many :telemetry_readings, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :documents, dependent: :nullify
  has_many :curricula, dependent: :destroy
  has_many :training_assignments, dependent: :destroy

  has_many_attached :sops

  validates :vin, presence: true, uniqueness: {scope: :organization_id}
  validates :sops,
    content_type: {in: %w[application/pdf], message: "must be PDFs"},
    allow_blank: true

  aasm column: :status do
    state :active, initial: true
    state :inactive
    state :maintenance

    event :deactivate do
      transitions from: :active, to: :inactive
    end

    event :begin_maintenance do
      transitions from: :active, to: :maintenance
    end

    event :complete_maintenance do
      transitions from: :maintenance, to: :active
    end

    event :activate do
      transitions from: :inactive, to: :active
    end
  end
end
