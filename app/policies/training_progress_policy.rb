class TrainingProgressPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owner_or_supervisor?
  end

  def create?
    record.training_assignment.user_id == user.id
  end

  def update?
    record.training_assignment.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_org_user?
        scope.all
      elsif user.admin? || user.manager?
        scope.joins(training_assignment: :user)
             .where(users: { organization_id: user.organization_id })
      else
        scope.joins(:training_assignment)
             .where(training_assignments: { user_id: user.id })
      end
    end
  end

  private

  def owner_or_supervisor?
    return true if admin_org_user?
    return true if record.training_assignment.user_id == user.id
    user.admin? || user.manager?
  end
end
