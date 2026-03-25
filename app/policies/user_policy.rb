class UserPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.admin?
  end

  def show?
    user.super_admin? || same_organization? || own_record?
  end

  def create?
    user.super_admin? || user.admin?
  end

  def update?
    user.super_admin? || (user.admin? && same_organization?) || own_record?
  end

  def destroy?
    user.super_admin? || (user.admin? && same_organization? && !own_record?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
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
