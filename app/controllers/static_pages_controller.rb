class StaticPagesController < ApplicationController
  def home
    #create an associated blank micropost if the user is signed in.
    if signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.page(params[:page]).limit(10)
    end
  end

  def help
  end

  def about
  end


  def contact
  end
end
