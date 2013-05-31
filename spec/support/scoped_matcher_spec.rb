##Created module as in excercise 8.5.2 
#Example on how to add the helper in the config is in the spec_helper file
module Helper
  def signin(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
  end

  def valid_signup
    fill_in "Name", with: "Example User"
    fill_in "Email", with: "mmart@example.com"
    fill_in "Password", with: "foobar"
    fill_in "Confirm Password", with: "foobar"
  end

  RSpec::Matchers.define :have_error_message do |message|
    match do |page|
      page.should have_selector('div.alert.alert-error', text: message)
    end
  end

  RSpec::Matchers.define :have_success_message do |message|
    match do |page|
      page.should have_selector('div.alert.alert-success', text: message)
    end
  end
end