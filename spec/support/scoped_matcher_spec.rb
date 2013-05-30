##Created module as in excercise 8.5.2 
#Example on how to add the helper in the config is in the spec_helper file
module Helper
  def valid_signin(user)
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end

  def valid_signup
    fill_in "Name", with: "Example User"
    fill_in "Email", with: "mmart@example.com"
    fill_in "Password", with: "foobar"
    fill_in "Confirmation", with: "foobar"
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