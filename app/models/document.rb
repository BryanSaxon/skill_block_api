class Document < ApplicationRecord
  belongs_to :organization
  belongs_to :organization_machine, optional: true
  has_many :document_chunks, dependent: :destroy
  has_one_attached :file

  enum :status, {
    processing: "processing",
    ready: "ready",
    used: "used",
    error: "error"
  }, validate: true

  validates :name, presence: true
  validates :document_type, presence: true, inclusion: { in: %w[sop manual reference] }
  validates :file, content_type: { in: %w[application/pdf], message: "must be a PDF" },
                   allow_blank: true

  scope :by_organization, ->(org_id) { where(organization_id: org_id) }
end
