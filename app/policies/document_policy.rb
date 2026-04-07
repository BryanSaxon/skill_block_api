class DocumentPolicy < ApplicationPolicy
  def index?
    can_manage_content?
  end

  def show?
    can_manage_content?
  end

  def create?
    can_manage_content?
  end

  def update?
    can_manage_content?
  end

  def destroy?
    admin_org_user? || user.admin?
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

  def can_manage_content?
    admin_org_user? || (user.admin? && user.organization_id == record.organization_id)
  end
end
