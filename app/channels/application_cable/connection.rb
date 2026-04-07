module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private

    # Flutter client connects via:
    #   ws://host/cable?token=<jwt>
    # The JWT is the same token issued by POST /session.
    def set_current_user
      token = request.params[:token]
      return false unless token.present?

      payload = JsonWebToken.decode(token)
      session = Session.find(payload[:sub])
      self.current_user = session.user
      true
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      false
    end
  end
end
