class ManagerDashboardController < ApplicationController
  def show
    unless current_user.admin_org_user? || current_user.admin? || current_user.manager?
      return render json: {error: "Forbidden"}, status: :forbidden
    end

    render json: {
      overdue_assignments: overdue_assignments_data,
      unassigned_operators: unassigned_operators_data,
      machines_with_critical_alerts: machines_with_critical_alerts_data
    }
  end

  private

  def scoped_users
    if current_user.manager?
      current_user.direct_reports
    elsif current_user.admin?
      User.where(organization_id: current_user.organization_id, role: :operator)
    else
      User.where(role: :operator)
    end
  end

  def overdue_assignments_data
    assignments = TrainingAssignment
      .where("training_assignments.due_date < ? AND training_assignments.status != ?", Date.current, "completed")
      .joins(:user)
      .where(users: {id: scoped_users.select(:id)})
      .includes(:user, :curriculum, :organization_machine)

    assignments.map do |a|
      {
        id: a.id,
        user: {id: a.user_id, name: "#{a.user.first_name} #{a.user.last_name}"},
        curriculum_title: a.curriculum.title,
        machine_nickname: a.organization_machine.nickname,
        due_date: a.due_date,
        status: a.status
      }
    end
  end

  def unassigned_operators_data
    operator_ids = scoped_users.pluck(:id)
    assigned_ids = UserOrganizationMachine.where(user_id: operator_ids).pluck(:user_id)
    unassigned = scoped_users.where.not(id: assigned_ids).select(:id, :first_name, :last_name, :email)
    unassigned.map { |u| {id: u.id, name: "#{u.first_name} #{u.last_name}", email: u.email} }
  end

  def machines_with_critical_alerts_data
    org_ids = if current_user.admin_org_user?
      Organization.all.select(:id)
    else
      Organization.where(id: current_user.organization_id).select(:id)
    end

    Alert.where(severity: :critical, resolved_at: nil)
      .joins(:organization_machine)
      .where(organization_machines: {organization_id: org_ids})
      .includes(:organization_machine)
      .group_by(&:organization_machine)
      .map do |machine, alerts|
        {
          machine_id: machine.id,
          machine_nickname: machine.nickname,
          critical_alert_count: alerts.size,
          oldest_alert_at: alerts.map(&:created_at).min
        }
      end
  end
end
