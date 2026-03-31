class OrganizationMachinePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.owner? || ((user.admin? || user.manager?) && same_organization?) || assigned_operator?
  end

  def create?
    user.owner? || (user.admin? && same_organization?)
  end

  def update?
    user.owner? || (user.admin? && same_organization?) || (user.manager? && same_organization?)
  end

  def destroy?
    user.owner? || (user.admin? && same_organization?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner?
        scope.all
      elsif user.admin? || user.manager?
        scope.where(organization: user.organization)
      else
        scope.joins(:user_organization_machines).where(user_organization_machines: {user_id: user.id})
      end
    end
  end

  private

  def same_organization?
    record.organization_id == user.organization_id
  end

  def assigned_operator?
    user.operator? && record.user_organization_machines.exists?(user_id: user.id)
  end
end
