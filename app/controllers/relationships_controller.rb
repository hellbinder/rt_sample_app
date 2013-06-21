class RelationshipsController < ApplicationController
  respond_to :html, :js
  before_filter :signed_in_user #make sure that a user it's signed in
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_with @user
  end

  def destroy
    #@user = User.find(params[:id])
    # I Was doing this which caused it to call teh user. The problem is the form is not sending in
    # the user idm but the RELATIONSHIP ID. Which we use to then get the user it's looking for. (followed)

    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_with @user
    
  end

end