class TrainingAssignmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if admin_org_user?
    return true if record.user_id == user.id
    return false unless same_organization?
    user.admin? || user.manager?
  end

  def create?
    admin_org_user? || (same_organization? && (user.admin? || user.manager?))
  end

  def update?
    admin_org_user? || (same_organization? && (user.admin? || user.manager?))
  end

  def destroy?
    admin_org_user? || (same_organization? && (user.admin? || user.manager?))
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      elsif user.admin? || user.manager?
        scope.joins(:user).where(users: {organization_id: user.organization_id})
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def same_organization?
    record.user.organization_id == user.organization_id
  end
end
