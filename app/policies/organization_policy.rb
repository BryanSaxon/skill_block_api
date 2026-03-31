class OrganizationPolicy < ApplicationPolicy
  def index?
    user.owner? || user.admin? || user.manager? || user.operator?
  end

  def show?
    user.owner? || same_organization?
  end

  def create?
    user.owner?
  end

  def update?
    user.owner? || (user.admin? && same_organization?)
  end

  def destroy?
    user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner?
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
