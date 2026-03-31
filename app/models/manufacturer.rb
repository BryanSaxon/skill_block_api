class Manufacturer < ApplicationRecord
  has_many :machines, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
