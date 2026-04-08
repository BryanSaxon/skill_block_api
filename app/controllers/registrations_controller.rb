class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_invitation_by_token

  def show
    render json: {
      email: @invitation.email,
      organization_name: @invitation.organization.name,
      role: @invitation.role
    }
  end

  def create
    user = @invitation.organization.users.new(
      email: @invitation.email,
      role: @invitation.role,
      first_name: params[:first_name],
      last_name: params[:last_name],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if user.save
      @invitation.update_column(:accepted_at, Time.current)
      start_new_session_for(user)
      token = JsonWebToken.encode(sub: Current.session.id)
      render json: {token: token, user: UserSerializer.new(user).serializable_hash}, status: :created
    else
      render json: {errors: user.errors.full_messages}, status: :unprocessable_content
    end
  end

  private

  def set_invitation_by_token
    @invitation = Invitation.find_by(token: params[:token])
    unless @invitation&.pending?
      render json: {error: "Invitation is invalid or has expired."}, status: :unprocessable_content
    end
  end
end
