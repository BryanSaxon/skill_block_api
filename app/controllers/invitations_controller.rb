class InvitationsController < ApplicationController
  before_action :set_organization

  def index
    invitations = policy_scope(Invitation).where(organization: @organization)
    render json: InvitationSerializer.new(invitations).serializable_hash
  end

  def create
    invitation = @organization.invitations.new(invitation_params.merge(invited_by: current_user))
    authorize invitation

    if invitation.save
      InvitationsMailer.invite(invitation).deliver_later
      render json: InvitationSerializer.new(invitation).serializable_hash, status: :created
    else
      render json: {errors: invitation.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    invitation = @organization.invitations.find(params[:id])
    authorize invitation
    invitation.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def invitation_params
    params.permit(:email, :role)
  end
end
