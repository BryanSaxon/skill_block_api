class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :organization
  has_one_attached :avatar

  enum :role, {super_admin: 0, admin: 1, manager: 2, employee: 3}, validate: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :avatar, content_type: {in: %w[image/png image/jpeg image/svg+xml], message: "must be a PNG, JPG, or SVG"}, allow_blank: true
  validate :super_admin_valid?

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt.last(10)
  end

  private

  def super_admin_valid?
    if super_admin? && organization&.name != Organization::SKILL_BLOCK_NAME
      errors.add(:role, "The super_admin role is restricted.")
    end
  end
end
