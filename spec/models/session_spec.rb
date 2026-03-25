require "rails_helper"

RSpec.describe Session, type: :model do
  it { is_expected.to belong_to(:user) }

  it "is created with ip_address and user_agent" do
    user = create(:user)
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
    expect(session).to be_persisted
  end

  it "is destroyed when the user is destroyed" do
    user = create(:user)
    user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
    expect { user.destroy }.to change(Session, :count).by(-1)
  end
end
