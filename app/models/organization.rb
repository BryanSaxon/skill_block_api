class Organization < ApplicationRecord
  SKILL_BLOCK_NAME = "Skill Block"

  enum :org_type, {admin: 0, client: 1}, validate: true

  has_many :users, dependent: :destroy
  has_many :organization_machines, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :curricula, class_name: "Curriculum", dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true, uniqueness: true
  validates :logo, content_type: {in: %w[image/png image/jpeg image/svg+xml], message: "must be a PNG, JPG, or SVG"}, allow_blank: true
  validate :only_one_admin_org

  private

  def only_one_admin_org
    return unless admin?
    if Organization.where(org_type: :admin).where.not(id: id).exists?
      errors.add(:org_type, "only one admin organization is allowed")
    end
  end
end
