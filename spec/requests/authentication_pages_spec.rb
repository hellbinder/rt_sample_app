require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "sign in page" do  
    before { visit signin_path }
    it { should have_selector("h1", text: "Sign in") }
    it { should have_selector("title", text: "Sign in") }
    it { should have_selector("input", id: "email") }
    it { should have_selector("input", id: "password") }
    it { should have_link("Sign up now!", href: signup_path) }
    it { should have_link("Click here to reset it", href: new_password_reset_path) }
  end

  describe "signin" do
    describe "user not signedin" do
      let(:user) {  FactoryGirl.create(:user) }  
      before { visit signin_path }
       #make sure user is signed out
      it { should_not have_link("Profile") }
      it { should_not have_link("Settings") }
    end
    describe "with valid information" do
      describe "when account is not active" do
        let (:user) { FactoryGirl.create(:non_active_user)}
        before { sign_in user }
        it { should have_selector("title", text: "Sign in") }
        it { should have_error_message("The account has not been activated.")}
      end
      describe "when account is active" do
        let (:user) { FactoryGirl.create(:user)}
        before { sign_in user }
        it { should have_selector("title", text: user.name) }
        it { should have_link("Profile", href: user_path(user)) }
        it { should have_link("Settings", href: edit_user_path(user)) }
        it { should have_link("Sign out", href: signout_path) }
        it { should have_link("Users", href: users_path) }
        it { should_not have_link("Sign in", href: signin_path) }

        describe "followed by signout" do
          before { click_link "Sign out" }
          it { should have_link('Sign in', url: signin_path) }
        end
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
      #testing not signedin, therefore no signin user method called
      let(:user) {  FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector("title", text: "Sign in") }
        end

        describe "submitting to the update action" do
            before { put user_path(user) }
            specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the users index" do
          before { visit users_path }
          it { should have_selector("title", text: "Sign in") }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user) #should get kicked out to sign in page
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in" #When signed in, should go back to the page he was trying to access.
        end

        describe "in the Microposts controller" do

          describe "submitting to the create action" do
            before { post microposts_path }
            specify { expect(response).to redirect_to(signin_path) }
          end

          describe "submitting to the destroy action" do
            before { delete micropost_path(FactoryGirl.create(:micropost)) }
            specify { expect(response).to redirect_to(signin_path) }
          end
        end      

        describe "in the Relationships controller" do

          describe "submitting the create action" do
            before { post relationships_path }
            specify { expect(response).to redirect_to(signin_path) } 
          end            

          describe "submitting the destroy action" do
            before { delete relationship_path(2) } #hard coded value...so as not to have to create one (11.33)
            specify { expect(response).to redirect_to(signin_path) } 
          end
        end

        describe "after signing in" do
          
          describe "it should be on desired protected page" do
            it { should have_selector('title', text: full_title('Edit User')) }
          end

          describe "when signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end

            it "should render the default page (profile)" do
              page.should have_selector("title", text: user.name)
            end
        end
      end
    end

      describe "as a wrong user" do
        let(:user) { FactoryGirl.create(:user) }
        let (:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
        before { sign_in user }

        describe "visiting Users#edit page" do
          before { visit edit_user_path(wrong_user) }
          it { should_not have_selector('title', text: full_title('Edit User')) }
        end

        describe "submitting a PUT request to the Users#update action" do
          before { put user_path(wrong_user) }
         specify { expect(response).to redirect_to(root_path) }
        end

      end
    end
  end
end
