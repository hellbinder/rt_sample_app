class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  # Force signout to prevent CSRF attacks
  def handle_unverified_request
    # add an additional cross-site request forgery safeguard
    sign_out
    super
  end

#Saw this online. Don't know if it works.
  def not_found
    raise ActiveRecord::RecordNotFound.new('Not Found')
  end

end
