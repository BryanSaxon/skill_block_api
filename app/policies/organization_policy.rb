class OrganizationPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.admin? || user.manager? || user.operator?
  end

  def show?
    user.super_admin? || same_organization?
  end

  def create?
    user.super_admin?
  end

  def update?
    user.super_admin? || (user.admin? && same_organization?)
  end

  def destroy?
    user.super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(id: user.organization_id)
      end
    end
  end

  private

  def same_organization?
    record.id == user.organization_id
  end
end
