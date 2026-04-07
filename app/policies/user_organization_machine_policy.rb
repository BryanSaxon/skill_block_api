class UserOrganizationMachinePolicy < ApplicationPolicy
  def index?
    admin_org_user? || user.admin? || user.manager?
  end

  def show?
    admin_org_user? || user.admin? || user.manager?
  end

  def create?
    return true if admin_org_user?
    return false unless same_organization?
    return true if user.admin?
    user.manager? && assignee_is_direct_report?
  end

  def destroy?
    return true if admin_org_user?
    return false unless same_organization?
    return true if user.admin?
    user.manager? && assignee_is_direct_report?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      elsif user.manager?
        scope.joins(:user, :organization_machine)
          .where(organization_machines: {organization_id: user.organization_id})
          .where(users: {manager_id: user.id})
      else
        scope.joins(:organization_machine).where(organization_machines: {organization_id: user.organization_id})
      end
    end
  end

  private

  def same_organization?
    record.organization_machine.organization_id == user.organization_id
  end

  def assignee_is_direct_report?
    User.find_by(id: record.user_id)&.manager_id == user.id
  end
end
