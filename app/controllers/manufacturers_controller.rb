class ManufacturersController < ApplicationController
  before_action :set_manufacturer, only: %i[show update destroy]

  def index
    authorize Manufacturer
    manufacturers = policy_scope(Manufacturer)
    render json: ManufacturerSerializer.new(manufacturers).serializable_hash
  end

  def show
    authorize @manufacturer
    render json: ManufacturerSerializer.new(@manufacturer).serializable_hash
  end

  def create
    manufacturer = Manufacturer.new(manufacturer_params)
    authorize manufacturer

    if manufacturer.save
      render json: ManufacturerSerializer.new(manufacturer).serializable_hash, status: :created
    else
      render json: {errors: manufacturer.errors.full_messages}, status: :unprocessable_content
    end
  end

  def update
    authorize @manufacturer

    if @manufacturer.update(manufacturer_params)
      render json: ManufacturerSerializer.new(@manufacturer).serializable_hash
    else
      render json: {errors: @manufacturer.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @manufacturer
    @manufacturer.destroy
    head :no_content
  end

  private

  def set_manufacturer
    @manufacturer = Manufacturer.find(params[:id])
  end

  def manufacturer_params
    params.permit(:name)
  end
end
