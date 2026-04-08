class CurriculumPolicy < ApplicationPolicy
  # Operators can read published curricula assigned to them.
  # Admins and managers can read all curricula in their org.
  # Only admins can create/edit/archive.

  def index?
    true
  end

  def show?
    return true if admin_org_user?
    return false unless same_organization?
    return true if user.admin? || user.manager?
    user.operator? && record.published? && assigned_to_user?
  end

  def create?
    admin_org_user? || (user.admin? && same_organization?)
  end

  def update?
    admin_org_user? || (user.admin? && same_organization?)
  end

  def destroy?
    admin_org_user? || (user.admin? && same_organization?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      elsif user.admin? || user.manager?
        scope.where(organization_id: user.organization_id)
      else
        scope.joins(:training_assignments)
          .where(training_assignments: {user_id: user.id})
          .where(status: "published")
      end
    end
  end

  private

  def same_organization?
    record.organization_id == user.organization_id
  end

  def assigned_to_user?
    record.training_assignments.exists?(user_id: user.id)
  end
end
