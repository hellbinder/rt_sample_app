require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create :user }
  describe "signup_confirmation" do
    let(:mail) { UserMailer.signup_confirmation(user) }

    it "renders the headers" do
      mail.subject.should eq("Signup confirmation")
      mail.to.should eq([user.email])
      mail.from.should eq(["super_admin@gmail.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Welcome to the site!")
    end
  end

  describe "follower_confirmation" do
    let(:mail) { UserMailer.follower_confirmation(follower, user) }
    let(:follower) { FactoryGirl.create :user }
    it "renders the headers" do
      mail.subject.should eq("You have a new follower!")
      mail.to.should eq([user.email])
      mail.from.should eq(["super_admin@gmail.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("You are now being followed by")
    end
  end

end
