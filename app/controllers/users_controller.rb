class UsersController < ApplicationController
  before_filter :get_user, only: [:show, :edit, :update, :destroy, :following, :followers]
  before_filter :signed_in_user, only: [:index, :edit, :update, :followers, :following]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:destroy]

  def index
    @users = User.search(params[:search]).page(params[:page] || 1).limit(10)
  end

  def new
    redirect_to root_url if signed_in?
     @user = User.new
  end

  def show
    @microposts = @user.microposts.page(params[:page] || 1)
  end

  def create
    if signed_in?
      redirect_to root_url
    else
      @user = User.new(params[:user])
      if @user.save
        flash[:success] = "Welcome to the sample application #{@user.name}"
        UserMailer.signup_confirmation(@user).deliver
        sign_in @user
        redirect_to @user
      else
        render 'new'
      end
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Your account was updated successfully"
      #Note that we sign in the user as part of a successful profile update; this is because the remember 
      #token gets reset when the user is saved (Listing 8.18), which invalidates the user’s session (Listing 8.22). This is a nice security feature, as it means that any hijacked sessions will automatically expire when the user information is changed.
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    if current_user.admin?
      name = @user.name
      @user.destroy
      flash[:success] = "User #{name} was destroyed."
      redirect_to users_path
    else
      redirect_to root_url
    end
  end

  def following
    @title = "Following"
    @users = @user.followed_users.page(params[:page] || 1)
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @users = @user.followers.page(params[:page] || 1)
    render "show_follow"
  end
private

  def get_user
    @user = User.find(params[:id])
  end

  def correct_user
    redirect_to root_path unless current_user?(@user)
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end

end
