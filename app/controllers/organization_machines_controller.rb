class OrganizationMachinesController < ApplicationController
  before_action :set_organization
  before_action :set_organization_machine, only: %i[show update destroy]

  def index
    authorize OrganizationMachine
    organization_machines = policy_scope(OrganizationMachine).where(organization: @organization)
    render json: OrganizationMachineSerializer.new(organization_machines).serializable_hash
  end

  def show
    authorize @organization_machine
    render json: OrganizationMachineSerializer.new(@organization_machine).serializable_hash
  end

  def create
    organization_machine = @organization.organization_machines.new(organization_machine_create_params)
    authorize organization_machine

    if organization_machine.save
      render json: OrganizationMachineSerializer.new(organization_machine).serializable_hash, status: :created
    else
      render json: {errors: organization_machine.errors.full_messages}, status: :unprocessable_content
    end
  end

  def update
    authorize @organization_machine

    if params[:event].present?
      trigger_event(@organization_machine, params[:event])
    elsif @organization_machine.update(organization_machine_update_params)
      render json: OrganizationMachineSerializer.new(@organization_machine).serializable_hash
    else
      render json: {errors: @organization_machine.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @organization_machine
    @organization_machine.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_organization_machine
    @organization_machine = @organization.organization_machines.find(params[:id])
  end

  def organization_machine_create_params
    params.permit(:machine_id, :vin, :nickname)
  end

  def organization_machine_update_params
    params.permit(:nickname, sops: [])
  end

  def trigger_event(organization_machine, event)
    allowed_events = %w[activate deactivate begin_maintenance complete_maintenance]

    unless allowed_events.include?(event)
      render json: {errors: ["Unknown event: #{event}"]}, status: :unprocessable_content
      return
    end

    organization_machine.send(:"#{event}!")
    render json: OrganizationMachineSerializer.new(organization_machine).serializable_hash
  rescue AASM::InvalidTransition => e
    render json: {errors: [e.message]}, status: :unprocessable_content
  end
end
