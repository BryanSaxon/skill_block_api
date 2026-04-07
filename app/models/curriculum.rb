class Curriculum < ApplicationRecord
  self.table_name = "curricula"

  belongs_to :organization
  belongs_to :organization_machine
  has_many :curriculum_modules, -> { order(:position) }, dependent: :destroy
  has_many :training_assignments, dependent: :destroy

  enum :role_level, { entry: "entry", experienced: "experienced", lead: "lead" }, validate: true
  enum :status, {
    generating: "generating",
    draft: "draft",
    published: "published",
    archived: "archived"
  }, validate: true

  validates :title, presence: true
  validates :role_level, presence: true
  validates :status, presence: true

  scope :published, -> { where(status: "published") }
end
