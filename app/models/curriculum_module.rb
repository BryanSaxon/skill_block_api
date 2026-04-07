class CurriculumModule < ApplicationRecord
  belongs_to :curriculum
  has_many :training_progresses, dependent: :destroy

  enum :module_type, { content: "content", quiz: "quiz" }, validate: true
  enum :review_status, {
    unreviewed: "unreviewed",
    reviewed: "reviewed",
    needs_attention: "needs_attention"
  }, validate: true

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :module_type, presence: true
end
