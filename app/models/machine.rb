class Machine < ApplicationRecord
  belongs_to :manufacturer
  has_many :organization_machines, dependent: :destroy

  has_one_attached :manual

  validates :name, presence: true
  validates :model_number, presence: true, uniqueness: {scope: :manufacturer_id}
  validates :manual, content_type: {in: %w[application/pdf], message: "must be a PDF"}, allow_blank: true
end
