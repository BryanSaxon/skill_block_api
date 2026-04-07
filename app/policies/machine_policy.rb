class MachinePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin_org_user?
  end

  def update?
    admin_org_user?
  end

  def destroy?
    admin_org_user?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
