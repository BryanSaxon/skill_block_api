class UserPolicy < ApplicationPolicy
  def index?
    admin_org_user? || user.admin? || user.manager?
  end

  def show?
    admin_org_user? || same_organization? || own_record?
  end

  def create?
    admin_org_user? || (user.admin? && same_organization?)
  end

  def update?
    admin_org_user? || (user.admin? && same_organization?) || own_record?
  end

  def destroy?
    admin_org_user? || (user.admin? && same_organization? && !own_record?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      elsif user.manager?
        scope.where(organization: user.organization).where("users.id = ? OR users.manager_id = ?", user.id, user.id)
      else
        scope.where(organization: user.organization)
      end
    end
  end

  private

  def same_organization?
    record.organization_id == user.organization_id
  end

  def own_record?
    record.id == user.id
  end
end
