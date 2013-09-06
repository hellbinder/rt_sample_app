class SessionsController < ApplicationController
  def new
    
  end

  def create
    user = User.find_by_username(params[:email].downcase) || User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      #Sign in user and redirect to his profile (user's show)
       if user.active?
        sign_in user
        redirect_back_or user
     else
        flash.now[:error] = "The account has not been activated. If you are still having problems please contact <a href='http://www.google.com'>us</a>".html_safe
        render "new"
      end
    else
      # Create error message and return to sign in page
      #flash.now = specifically designed for displaying flash messages on rendered pages
      flash.now[:error] = 'Invalid email/password combination'
      render "new"
      # since it's a redirect it won't count as another request so flash messages will stay for the next render.
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
