class MachineParameter < ApplicationRecord
  belongs_to :organization_machine

  validates :name, presence: true,
    uniqueness: {scope: :organization_machine_id, case_sensitive: false}
  validates :display_order, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  default_scope { order(:display_order) }
end
