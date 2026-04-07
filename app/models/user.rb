class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_organization_machines, dependent: :destroy
  has_many :organization_machines, through: :user_organization_machines
  has_many :notifications, dependent: :destroy
  has_many :resolved_alerts, class_name: "Alert", foreign_key: :resolved_by_id, dependent: :nullify

  belongs_to :organization
  has_one_attached :avatar

  enum :role, {admin: 0, manager: 1, operator: 2}, validate: true

  belongs_to :manager, class_name: "User", optional: true, foreign_key: :manager_id
  has_many :direct_reports, class_name: "User", foreign_key: :manager_id, dependent: :nullify

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :avatar, content_type: {in: %w[image/png image/jpeg image/svg+xml], message: "must be a PNG, JPG, or SVG"}, allow_blank: true
  validate :manager_assignment_valid?

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt.last(10)
  end

  def admin_org_user?
    organization&.admin?
  end

  private

  def manager_assignment_valid?
    return unless manager_id.present?
    errors.add(:manager, "must be in the same organization") if manager&.organization_id != organization_id
    errors.add(:manager, "can only be set on operators") unless operator?
    errors.add(:manager, "must have the manager role") unless manager&.manager?
  end
end
