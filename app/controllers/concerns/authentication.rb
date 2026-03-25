module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    token = bearer_token
    return false unless token

    payload = JsonWebToken.decode(token)
    Current.session = Session.find(payload[:sub])
    true
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    false
  end

  def request_authentication
    render json: {error: "Unauthorized"}, status: :unauthorized
  end

  def start_new_session_for(user)
    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    ).tap { |session| Current.session = session }
  end

  def terminate_session
    Current.session.destroy
  end

  def bearer_token
    header = request.headers["Authorization"]
    header&.start_with?("Bearer ") ? header.split(" ").last : nil
  end
end
