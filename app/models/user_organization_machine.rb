class UserOrganizationMachine < ApplicationRecord
  belongs_to :user
  belongs_to :organization_machine

  validates :user_id, uniqueness: {scope: :organization_machine_id}
end
