class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset
    redirect_to signin_path, notice: "An email has been sent to the specified address with instructions on how to reset your password"
  end

  def edit
    @user = User.find_by_password_reset_hash!(params[:id])
  end

end
