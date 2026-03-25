class SessionsController < ApplicationController
  allow_unauthenticated_access only: :create
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render json: {error: "Too many requests"}, status: :too_many_requests }

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user
      start_new_session_for(user)
      token = JsonWebToken.encode(sub: Current.session.id)
      render json: {token: token, user: UserSerializer.new(user).serializable_hash}, status: :created
    else
      render json: {error: "Invalid email or password"}, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    head :no_content
  end
end
