class UserOrganizationMachinePolicy < ApplicationPolicy
  def index?
    user.owner? || user.admin? || user.manager?
  end

  def show?
    user.owner? || user.admin? || user.manager?
  end

  def create?
    user.owner? || (user.admin? && same_organization?)
  end

  def destroy?
    user.owner? || (user.admin? && same_organization?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner?
        scope.all
      else
        scope.joins(:organization_machine).where(organization_machines: {organization_id: user.organization_id})
      end
    end
  end

  private

  def same_organization?
    record.organization_machine.organization_id == user.organization_id
  end
end
