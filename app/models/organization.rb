class Organization < ApplicationRecord
  SKILL_BLOCK_NAME = "Skill Block"

  has_many :users, dependent: :destroy
  has_many :organization_machines, dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true, uniqueness: true
  validates :logo, content_type: {in: %w[image/png image/jpeg image/svg+xml], message: "must be a PNG, JPG, or SVG"}, allow_blank: true
end
