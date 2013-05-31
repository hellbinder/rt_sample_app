require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "sign in page" do    
    before { visit signin_path }
    it { should have_selector("h1", text: "Sign in") }
    it { should have_selector("title", text: "Sign in") }
  end

  describe "signin" do
    describe "with valid information" do
      let (:user) { FactoryGirl.create(:user)}
      before { signin user }
      it { should have_selector("title", text: user.name) }
      it { should have_link("Profile", href: user_path(user)) }
      it { should have_link("Settings", href: edit_user_path(user)) }
      it { should have_link("Sign out", href: signout_path) }
      it { should_not have_link("Sign in", href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in', url: signin_path) }
      end
    end

    describe "with invalid information" do
      before { visit signin_path }
      before { click_button "Sign in"}

      it { should have_selector("title", text: "Sign in") }
      it { should have_error_message("Invalid") }

      describe "after visiting another page" do
        #makes sure that the flash message does not persist.
        before { click_link "Home" }
        it { should_not have_error_message("Invalid") }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed in users" do
      #testing not signedin, thereforeno signin user method called
      let(:user) {  FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector("title", text: "Sign in") }
        end

        describe "submitting to the update action" do
            before { put user_path(user) }
            specify { response.should redirect_to(signin_path) }
        end
      end
    end
  end
end
