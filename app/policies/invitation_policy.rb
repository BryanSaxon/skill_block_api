class InvitationPolicy < ApplicationPolicy
  def index?
    admin_org_user? || (user.admin? && same_organization?)
  end

  def create?
    admin_org_user? || (user.admin? && same_organization?)
  end

  def destroy?
    admin_org_user? || (user.admin? && same_organization?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      else
        scope.where(organization_id: user.organization_id)
      end
    end
  end

  private

  def same_organization?
    record.organization_id == user.organization_id
  end
end
