class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show update destroy]

  def index
    authorize Organization
    organizations = policy_scope(Organization)
    render json: OrganizationSerializer.new(organizations).serializable_hash
  end

  def show
    authorize @organization
    render json: OrganizationSerializer.new(@organization).serializable_hash
  end

  def create
    organization = Organization.new(organization_params)
    authorize organization

    if organization.save
      if params[:admin_email].present?
        invitation = organization.invitations.create!(
          email: params[:admin_email],
          role: :admin,
          invited_by: current_user
        )
        InvitationsMailer.invite(invitation).deliver_later
      end
      render json: OrganizationSerializer.new(organization).serializable_hash, status: :created
    else
      render json: {errors: organization.errors.full_messages}, status: :unprocessable_content
    end
  end

  def update
    authorize @organization

    if @organization.update(organization_params)
      render json: OrganizationSerializer.new(@organization).serializable_hash
    else
      render json: {errors: @organization.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @organization
    @organization.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.permit(:name, :logo, :org_type)
  end
end
