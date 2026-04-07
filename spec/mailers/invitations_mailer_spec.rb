require "rails_helper"

RSpec.describe InvitationsMailer, type: :mailer do
  let(:organization) { create(:organization) }
  let(:admin_org_user) { create(:admin_org_user) }
  let(:invitation) { create(:invitation, organization: organization, invited_by: admin_org_user) }
  let(:mail) { described_class.invite(invitation) }

  it "sends to the invitation email address" do
    expect(mail.to).to eq([invitation.email])
  end

  it "includes the organization name in the subject" do
    expect(mail.subject).to include(organization.name)
  end

  it "includes the register URL in the body" do
    register_url = "#{ENV.fetch("CLIENT_URL", "http://localhost:8080")}/accept-invitation?token=#{invitation.token}"
    expect(mail.body.encoded).to include(register_url)
  end

  it "includes the token in the register URL" do
    expect(mail.body.encoded).to include(invitation.token)
  end
end
