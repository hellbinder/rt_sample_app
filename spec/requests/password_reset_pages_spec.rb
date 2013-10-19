require 'spec_helper'

describe "Password reset pages" do

  subject { page }

  let(:submit) {"Reset Password"}
  let(:user) { FactoryGirl.create :user }
  email_reset_notice = "An email has been sent to the specified address with instructions on how to reset your password"
  before { visit new_password_reset_path }

  describe "visit the password reset page" do
    it { should have_selector("label", text: "Email")}
    it { should have_selector("input#email") }
    it { should have_selector("title", text: "Reset Password")}
    describe "fill in email" do
      #should do the same for both as we don't want to let the user know thay there is an email exists in the system
      #Can this be refactored since it's actually doing the same process?
      describe "with any email" do
        let(:user) { FactoryGirl.create :user }
        before do 
          fill_in "email", with: user.email
          click_button submit
        end
        it { should have_notice_message email_reset_notice }
        it { current_path.should eq signin_path }
        it "should send a confirmation e-mail" do
          mail = ActionMailer::Base.deliveries.last
          mail.to.should eq([user.email])
          mail.body.should have_content "begin the process of resetting your password"
        end
      end
    end
  end
  describe "visit the password edit page" do
    before do
      user.password_reset_hash = SecureRandom.urlsafe_base64
      user.password_reset_sent_at = Time.zone.now
      user.save!
      visit edit_password_reset_path(user.password_reset_hash) 
       @old_encrypted_password = user.password_digest #Since password is not stored in db, I'll test with the old encrypted password
    end
    it { should have_selector("label", text: "Password")}
    it { should have_selector("label", text: "Confirm Password")}
    it { should have_selector("input#user_password") }
    it { should have_selector("input#user_password_confirmation") }
    it { should have_selector("title", text: "Reset Password")}

    describe "fill in password and submit" do
      before do
        fill_in "user_password", with: "1234567"
        fill_in "user_password_confirmation", with: "1234567"
        click_button submit
      end

      it "should go to his main page logged in and password changed" do
        user.reload.password_digest.should_not eq @old_encrypted_password
        current_path.should eq root_path
      end
    end
  end
    describe "visit the page with invalid token" do
      before do
        user.password_reset_hash = SecureRandom.urlsafe_base64
        user.save!
        visit edit_password_reset_path("123457")
      end
      specify { current_path.should eq signin_path }
    end

#NEED TO FIX THIS TEST (Refactor it someohow. had to recreate the whole process so it would work...stooooopid)
    describe "password sent is more than 2 hours old" do
      before do
        user.password_reset_hash = SecureRandom.urlsafe_base64
        user.password_reset_sent_at = Time.zone.now
        user.password_reset_sent_at -= 2.hours
        user.save!
        visit edit_password_reset_path(user.password_reset_hash) 
        fill_in "user_password", with: "1234567"
        fill_in "user_password_confirmation", with: "1234567"
        click_button submit
      end
      it "should be redirected to send password again" do
        current_path.should eq new_password_reset_path 
        should have_error_message("Password reset has expired")
      end
    end
end



