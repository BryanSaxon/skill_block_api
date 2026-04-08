class OrganizationMachinesController < ApplicationController
  before_action :set_organization
  before_action :set_organization_machine, only: %i[show update destroy transition]

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
    # Flutter sends name + machine_type to create/find the underlying Machine catalog entry,
    # plus nickname for the org-specific label and state for the initial AASM status.
    machine = find_or_create_machine(params[:name], params[:machine_type])
    unless machine
      return render json: {errors: ["Machine name is required"]}, status: :unprocessable_content
    end

    organization_machine = @organization.organization_machines.new(
      machine: machine,
      nickname: params[:nickname],
      vin: SecureRandom.hex(8)
    )
    # Allow caller to set initial status directly (active | inactive)
    if params[:state].present? && %w[active inactive].include?(params[:state])
      organization_machine.status = params[:state]
    end

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

  # POST /organizations/:organization_id/organization_machines/:id/transition
  def transition
    authorize @organization_machine, :update?
    trigger_event(@organization_machine, params[:event])
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_organization_machine
    @organization_machine = @organization.organization_machines.find(params[:id])
  end

  def find_or_create_machine(name, machine_type)
    return nil if name.blank?
    manufacturer = Manufacturer.find_or_create_by!(name: "Skill Block")
    Machine.find_or_create_by!(name: name, manufacturer: manufacturer) do |m|
      m.model_number = name.parameterize(separator: "-")
      m.description = machine_type.presence
    end
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
