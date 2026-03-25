class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @reset_token = user.password_reset_token
    mail subject: "Reset your password", to: user.email
  end
end
