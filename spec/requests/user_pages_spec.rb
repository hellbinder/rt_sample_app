require 'spec_helper'
require 'sidekiq/testing'

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
      specify { current_url.should == root_url}
      it { should have_selector('h1', text: user.name) }
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

        it { should have_success_message ("An email has been sent to confirm your identity. Go check it out!") }
        
        it "should send a confirmation e-mail" do
          process_async
          mail = ActionMailer::Base.deliveries.last
          mail.to.should == [user.email]
          mail.body.should have_content "verify your account"
        end

      end
    end

    describe "confirm user account" do
      let(:user) { FactoryGirl.create :non_active_user }
      let(:confirm_auth) { user.confirmation_hash }
      before { user.save }

      describe "when user does not exist" do
        before { visit confirm_user_path(999,222) }
        specify { current_path.should == root_path }
        it { should have_error_message("The user does not exist or has since been deleted.")}
      end

      describe "when user is already active" do
        before do
          user.toggle!(:active) #activate user
          visit confirm_user_path(user,234) # Does not care about the hash since it checks for user being active first.
        end
        #redirects with a notice
        specify { current_path.should == "/signin"} # current_path is supposed to be defined as part of the DSL that's included "include Capybara::DSL"
        it { should have_notice_message("This account is already confirmed! Please log in with your credentials to access the site.") }
      end

      describe "with wrong hash" do
        before { visit confirm_user_path(user,"13512") }
        #Redirects!
        specify { current_path.should == root_path } 
        it { should have_notice_message("Your confirmation key is incorrect.") }
      end

      describe "with correct hash" do
        before { visit confirm_user_path(user, confirm_auth) }

        #Make sure hes in the main page and logged in!
        it "should activate the user" do
          user.reload
          user.should be_active #should this be done here?! Or move it to user_specs?
        end
        it { should have_link("Profile", href: user_path(user)) }
        it { should have_link("Sign out", href: signout_path) }
        it { should_not have_link("Sign in", href: signin_path) }
        it { should have_success_message("Welcome") } #since when signing up should already log them in
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
        #it { should have_selector('h1', text: 'Welcome') }
      end 

    end

  end

  describe "profile page" do
    let (:user) { FactoryGirl.create(:user)}
    let (:other_user) { FactoryGirl.create(:user)}
    let!(:m1) { FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago) }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Oh hell not", created_at: 1.hour.ago) }
    let!(:m3) { FactoryGirl.create(:micropost, user: other_user, content: "reply to yo mother!", in_reply_to: m2.id, created_at: 2.hour.ago) }

    before do
      sign_in user
      visit user_path(user)
    end

    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) } 
    
    it "should see the delete link - should not see reply for each micropost" do
      user.microposts.each do |item|
        if item.in_reply_to.nil?
          page.should have_selector("li", text: item.content)
        else
          page.should have_selector("li.reply", text: item.content)
        end
        page.should have_link("delete", href: micropost_path(item) )
        page.should_not have_link("reply")
      end
    end

    describe "user stats" do
      before do
        user.relationships.create(followed_id: other_user.id) # add follower
        visit user_path(user)
      end
      it { should have_link("1 following", href: following_user_path(user)) }
      it { should have_link("0 follower", href: followers_user_path(user)) }
    end

    #This was extra excercise. I wasn't able to create a test without setting up everything again.
    describe "visit another user's profile" do
      let(:user) { FactoryGirl.create :user }
      let(:other_user) { FactoryGirl.create :user, email: "other_user@example.com" }
      let!(:m1) { FactoryGirl.create(:micropost, user: other_user, created_at: 1.day.ago) }
      let!(:m2) { FactoryGirl.create(:micropost, user: other_user, content: "Oh hell not", created_at: 1.hour.ago) }

      before do
        sign_in user
        visit user_path(other_user)
      end

      it "should not see the delete link and should see reply for each micropost" do
        other_user.microposts.each do |item|
          page.should have_selector("li", text: item.content)
          page.should_not have_link("delete", href: micropost_path(item) )
          page.should have_link("reply")
        end
      end
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create :user }
      before { sign_in user}

      describe "following a user" do
        before { visit user_path other_user }

        it "should increment the followed user count" do
          expect { click_button "Follow" }.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other users follower count" do
          expect{ click_button "Follow" }.to change(other_user.followers, :count).by(1)
        end

        describe "toggling button" do
          before { click_button "Follow" }
          it { should have_selector('input', value: 'Unfollow') }
        end

        describe "following email confirmation" do
          before { click_button "Follow" }
          it "should send email to user" do
            process_async
            mail = ActionMailer::Base.deliveries.last
            mail.to.should == [other_user.email]
            mail.subject.should == "You have a new follower!"
          end
        end

      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path other_user
        end

        it "should increment the followed user count" do
          expect { click_button "Unfollow" }.to change(user.followed_users, :count).by(-1)
        end

        it "should increment the other users follower count" do
          expect{ click_button "Unfollow" }.to change(other_user.followers, :count).by(-1)
        end

        describe "toggle button" do
          before { click_button "Unfollow" }
          it { should have_selector("input", value: "Follow") }
        end

      end

    end
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

    #done by me!
    describe "search functionality" do
      before(:all) { 5.times { FactoryGirl.create(:user) } }
      after (:all) { User.delete_all }

      #using let! so it created the user instantly. no laziness
      let!(:user2) { FactoryGirl.create(:user, username: "bmicahels", name: "Bob Michaels") }
      let!(:user3) { FactoryGirl.create(:user, username: "tripob", name: "Bobitch Tripod") }
      let!(:user4) { FactoryGirl.create(:user, username: "trinidadlav", name: "Trinidad Guslav") }

      it { should have_selector("input[type=text]", id:"search") }

      describe "searching for user" do
        describe "searching by name" do
          before do
            fill_in "search", with: "Bob"
            click_button "Search"
          end
          it { should have_selector("li", text: user2.name) } 
          it { should have_selector("li", text: user3.name) } 
          it { should_not have_selector("li", text: user4.name) }
        end

        describe "searching by username" do
          before do
            fill_in "search", with: "tri"
            click_button "Search"
          end
          it { should_not have_selector("li", text: user2.name) }
          it { should have_selector("li", text: user3.name) } 
          it { should have_selector("li", text: user4.name) } 
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

  describe "following/follower" do
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create :user }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in other_user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title("Following")) }
      it { should have_selector("h3", text: "Following") }
      it { should have_link(other_user.name, href: user_path(other_user)) }  
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector('title', text: full_title("Followers")) }
      it { should have_selector("h3", text: "Followers") }
      it { should have_link(user.name, href: user_path(user)) }  
    end
  end
end
