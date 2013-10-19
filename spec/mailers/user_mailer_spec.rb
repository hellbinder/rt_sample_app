require "spec_helper"

describe UserMailer do
  admin_email = "super_admin@gmail.com"
  let(:user) { FactoryGirl.create :non_active_user }
  describe "signup_confirmation" do
    let(:mail) { UserMailer.signup_confirmation(user) }

    it "renders the headers" do
      mail.subject.should eq("Signup confirmation")
      mail.to.should eq([user.email])
      mail.from.should eq([admin_email])
    end

    it "renders the body" do
      mail.body.encoded.should match("Thank you for you interest in the site!")
    end
  end

  describe "follower_confirmation" do
    let(:mail) { UserMailer.follower_confirmation(follower, user) }
    let(:follower) { FactoryGirl.create :user }
    it "renders the headers" do
      mail.subject.should eq("You have a new follower!")
      mail.to.should eq([user.email])
      mail.from.should eq([admin_email])
    end

    it "renders the body" do
      mail.body.encoded.should match("You are now being followed by")
    end
  end

  describe "password_reset" do
    let(:mail) { UserMailer.password_reset(user) } 
    it "renders the headers" do
      mail.subject.should eq("Reset your password")
      mail.to.should eq([user.email])
      mail.from.should eq([admin_email])
    end
  end

end
