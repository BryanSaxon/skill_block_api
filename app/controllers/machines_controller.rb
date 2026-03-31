class MachinesController < ApplicationController
  before_action :set_machine, only: %i[show update destroy]

  def index
    authorize Machine
    machines = policy_scope(Machine)
    render json: MachineSerializer.new(machines).serializable_hash
  end

  def show
    authorize @machine
    render json: MachineSerializer.new(@machine).serializable_hash
  end

  def create
    machine = Machine.new(machine_params)
    authorize machine

    if machine.save
      render json: MachineSerializer.new(machine).serializable_hash, status: :created
    else
      render json: {errors: machine.errors.full_messages}, status: :unprocessable_content
    end
  end

  def update
    authorize @machine

    if @machine.update(machine_params)
      render json: MachineSerializer.new(@machine).serializable_hash
    else
      render json: {errors: @machine.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @machine
    @machine.destroy
    head :no_content
  end

  private

  def set_machine
    @machine = Machine.find(params[:id])
  end

  def machine_params
    params.permit(:manufacturer_id, :name, :model_number, :description, :manual)
  end
end
