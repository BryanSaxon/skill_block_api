module JwtHelpers
  def auth_headers_for(user)
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
    token = JsonWebToken.encode(sub: session.id)
    {"Authorization" => "Bearer #{token}"}
  end
end

RSpec.configure do |config|
  config.include JwtHelpers, type: :request
end
