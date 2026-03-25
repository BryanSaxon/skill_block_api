class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: :update
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render json: {error: "Too many requests"}, status: :too_many_requests }

  def create
    user = User.find_by(email: params[:email])
    if user
      PasswordsMailer.reset(user).deliver_later
    end

    # Always return the same response to prevent email enumeration.
    # In development the reset_token is included for testing without email.
    response_body = {message: "If that email exists, reset instructions have been sent."}
    response_body[:reset_token] = user.password_reset_token if user && !Rails.env.production?
    render json: response_body
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      render json: {message: "Password updated successfully."}
    else
      render json: {errors: @user.errors.full_messages}, status: :unprocessable_content
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: {error: "Password reset link is invalid or has expired."}, status: :unprocessable_content
  end
end
