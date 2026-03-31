class UserPolicy < ApplicationPolicy
  def index?
    user.owner? || user.admin?
  end

  def show?
    user.owner? || same_organization? || own_record?
  end

  def create?
    user.owner? || user.admin?
  end

  def update?
    user.owner? || (user.admin? && same_organization?) || own_record?
  end

  def destroy?
    user.owner? || (user.admin? && same_organization? && !own_record?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner?
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
