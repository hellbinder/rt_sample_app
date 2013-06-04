require 'spec_helper'

describe "User Pages" do
  subject{ page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1', text: 'Sign Up') }
    it { should have_selector('title', text: full_title('Sign up')) }

    describe "already signed in" do
      let(:user) { FactoryGirl.create :user }
      before do
       sign_in user
       visit new_user_path
      end

      it { should have_selector('h1', text: 'Welcome') }
    end  
  end

  describe "signup" do
    before {visit signup_path}
    let(:submit) {"Create my Account"}

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.to_not change(User, :count)
      end

    describe "after submission" do
      before { click_button submit }

      it { should have_selector('title', text: 'Sign up') }
      it { should have_content('error') }
    end

    end
    describe "with valid information" do
      before do
        valid_signup
      end
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let (:user) { User.find_by_email('mmart@example.com') }

        it { should have_selector("title", text: user.name) }
        it { should have_link("Profile", href: user_path(user)) }
        it { should have_link("Sign out", href: signout_path) }
        it { should_not have_link("Sign in", href: signin_path) }
        it { should have_success_message('Welcome') } #since when signing up should already log them in.
      end
    end     

    describe "already logged in" do
      
      describe "attempting to request a user#create " do
        let(:user) { FactoryGirl.create :user }
        before do
         sign_in user
         visit new_user_path
         post users_path
        end

        specify { response.should redirect_to(root_url) }
        #t { should have_selector('h1', text: 'Welcome') }
      end 

    end


  end

  describe "profile page" do
    let (:user) { FactoryGirl.create(:user)}
    before {visit user_path(user)}
    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }  
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
     sign_in user
     visit edit_user_path(user) 
    end

    it { should have_selector("h1", text: "Update your profile") }
    it { should have_selector("title", text: "Edit User")}
    it { should have_link("change", href: "http://www.gravatar.com/emails") }

    describe "with invalid information" do
      before { click_button "Save" } 
      it { should have_content("error") }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "someemail@bs.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: "newpass"
        fill_in "Confirm Password", with: "newpass"
        click_button "Save changes"
      end

      it { should have_selector("title", text: new_name) }
      it { should have_selector("div.alert.alert-success", text: "updated successfully") }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_selector("h1", text: "All users") }
    it { should have_selector("title", text: "All users") }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after (:all) { User.delete_all }
      it { should have_selector ("div.pagination") }

      it "should list each user" do
        User.page(1).limit(10).each do |user|
          page.should have_selector("li", text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link("delete") } 

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end
        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end

      describe "as non-admin user" do
          let(:user) { FactoryGirl.create(:user) }
          let(:non_admin) { FactoryGirl.create(:user) }

          before { sign_in non_admin }

        describe "submitting a DELETE request to the Users#destroy action" do
          before { delete user_path(user) }
          specify { response.should redirect_to(root_url) }
        end
      end
    end
  end
end
