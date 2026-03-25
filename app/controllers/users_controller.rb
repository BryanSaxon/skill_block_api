class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  def index
    authorize User
    users = policy_scope(User)
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

    if @user.update(user_params)
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

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :avatar)
  end
end
