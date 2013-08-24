class UserMailer < ActionMailer::Base
  default from: "super_admin@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user)
    @user = user
    @greeting = "Thank you for you interest in the site! Please verify your account by clicking on the following link."

    mail to: user.email, subject: "Signup confirmation"
  end

  def signup_confirmation(user)
    @user = user
    @greeting = "Welcome to the site! This is a test site trying to understand the rails framework"

    mail to: user.email, subject: "Account confirmed!"
  end

  def follower_confirmation(follower, user)
    @user = user
    @follower = follower
    @greeting = "You have a new follower!"

    mail to: user.email, subject: "You have a new follower!"
  end
end
