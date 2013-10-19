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

  def update
    @user = User.find_by_password_reset_hash!(params[:id])
    if @user.update_attributes(params[:user])
      sign_in @user
      redirect_to root_url, notice: "The password has been changed successfully!!!"
    else
      render "edit"
    end
  end
end
