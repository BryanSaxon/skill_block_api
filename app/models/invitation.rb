class Invitation < ApplicationRecord
  belongs_to :organization
  belongs_to :invited_by, class_name: "User"

  enum :role, {admin: 0, manager: 1, operator: 2}, validate: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :email_not_already_registered
  validate :role_valid_for_org_type

  before_validation :set_token_and_expiry, on: :create

  def pending?
    !accepted? && !expired?
  end

  def accepted?
    accepted_at.present?
  end

  def expired?
    expires_at < Time.current
  end

  private

  def set_token_and_expiry
    self.token ||= SecureRandom.hex(32)
    self.expires_at ||= 48.hours.from_now
  end

  def email_not_already_registered
    errors.add(:email, "already has an account") if User.exists?(email:)
  end

  def role_valid_for_org_type
    errors.add(:role, "admin org users must have admin role") if organization&.admin? && !admin?
  end
end
