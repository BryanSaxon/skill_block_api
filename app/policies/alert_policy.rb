class AlertPolicy < ApplicationPolicy
  def index?
    can_read_machine?
  end

  def show?
    can_read_machine?
  end

  # Alerts are created by the simulator / background jobs, not end users.
  def create?
    false
  end

  # Operators and managers can acknowledge; admins can do anything.
  def acknowledge?
    return true if admin_org_user?
    return false unless same_organization?
    user.admin? || user.manager? || assigned_operator?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      elsif user.admin? || user.manager?
        scope.joins(:organization_machine).where(organization_machines: {organization_id: user.organization_id})
      else
        scope.joins(organization_machine: :user_organization_machines)
          .where(user_organization_machines: {user_id: user.id})
      end
    end
  end

  private

  def same_organization?
    record.organization_machine.organization_id == user.organization_id
  end

  def can_read_machine?
    return true if admin_org_user?
    return false unless same_organization?
    user.admin? || user.manager? || assigned_operator?
  end

  def assigned_operator?
    user.operator? && record.organization_machine
      .user_organization_machines
      .exists?(user_id: user.id)
  end
end
