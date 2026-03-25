class ApplicationController < ActionController::API
  include Authentication
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def current_user
    Current.user
  end

  def forbidden
    render json: {error: "Forbidden"}, status: :forbidden
  end

  def not_found
    render json: {error: "Not found"}, status: :not_found
  end
end
