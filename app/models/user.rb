class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_organization_machines, dependent: :destroy
  has_many :organization_machines, through: :user_organization_machines

  belongs_to :organization
  has_one_attached :avatar

  enum :role, {owner: 0, admin: 1, manager: 2, operator: 3}, validate: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :avatar, content_type: {in: %w[image/png image/jpeg image/svg+xml], message: "must be a PNG, JPG, or SVG"}, allow_blank: true
  validate :owner_valid?

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt.last(10)
  end

  private

  def owner_valid?
    if owner? && organization&.name != Organization::SKILL_BLOCK_NAME
      errors.add(:role, "The owner role is restricted.")
    end
  end
end
