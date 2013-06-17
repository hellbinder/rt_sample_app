##Created module as in excercise 8.5.2 
#Example on how to add the helper in the config is in the spec_helper file
module Helper
  def sign_in(user)
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

  RSpec::Matchers.define :be_valid do
  match do |actual|
    actual.valid?
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would be valid (errors: #{actual.errors.full_messages.inspect})"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be valid"
  end

  description do
    "be valid"
  end
end
end