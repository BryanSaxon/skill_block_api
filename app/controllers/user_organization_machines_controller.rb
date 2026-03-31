class UserOrganizationMachinesController < ApplicationController
  before_action :set_organization
  before_action :set_organization_machine

  def index
    authorize UserOrganizationMachine
    user_organization_machines = policy_scope(UserOrganizationMachine).where(organization_machine: @organization_machine)
    render json: UserOrganizationMachineSerializer.new(user_organization_machines).serializable_hash
  end

  def create
    user_organization_machine = @organization_machine.user_organization_machines.new(user_organization_machine_params)
    authorize user_organization_machine

    if user_organization_machine.save
      render json: UserOrganizationMachineSerializer.new(user_organization_machine).serializable_hash, status: :created
    else
      render json: {errors: user_organization_machine.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    user_organization_machine = @organization_machine.user_organization_machines.find(params[:id])
    authorize user_organization_machine
    user_organization_machine.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_organization_machine
    @organization_machine = @organization.organization_machines.find(params[:organization_machine_id])
  end

  def user_organization_machine_params
    params.permit(:user_id)
  end
end
