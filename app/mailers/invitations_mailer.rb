class InvitationsMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @org_name = invitation.organization.name
    @register_url = "#{ENV.fetch("CLIENT_URL", "http://localhost:8080")}/accept-invitation?token=#{invitation.token}"
    mail to: invitation.email, subject: "You've been invited to #{@org_name}"
  end
end
