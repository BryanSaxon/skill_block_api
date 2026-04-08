class UsersController < ApplicationController
  before_action :set_organization, only: %i[index show update destroy]
  before_action :set_user, only: %i[show update destroy]

  def index
    authorize User
    users = policy_scope(User).where(organization_id: @organization.id)
    render json: UserSerializer.new(users).serializable_hash
  end

  def show
    authorize @user
    render json: UserSerializer.new(@user).serializable_hash
  end

  def create
    organization = Organization.find(params[:organization_id])
    user = organization.users.build(user_params)
    authorize user

    if user.save
      render json: UserSerializer.new(user).serializable_hash, status: :created
    else
      render json: {errors: user.errors.full_messages}, status: :unprocessable_content
    end
  end

  def update
    authorize @user

    if params[:organization_machine_id].present?
      assign_machine_and_respond
    elsif @user.update(user_params)
      render json: UserSerializer.new(@user).serializable_hash
    else
      render json: {errors: @user.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_user
    @user = @organization.users.find(params[:id])
  end

  def assign_machine_and_respond
    org_machine = @organization.organization_machines.find(params[:organization_machine_id])
    # Replace any existing primary machine assignment
    @user.user_organization_machines.destroy_all
    @user.user_organization_machines.create!(organization_machine: org_machine)
    render json: UserSerializer.new(@user).serializable_hash
  rescue ActiveRecord::RecordNotFound
    render json: {errors: ["Machine not found"]}, status: :unprocessable_content
  rescue ActiveRecord::RecordInvalid => e
    render json: {errors: [e.message]}, status: :unprocessable_content
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :avatar, :manager_id)
  end
end
