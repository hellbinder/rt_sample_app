require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create :user }
  before do
    @micropost = user.microposts.build(content: "Lorem insum")
  end
  subject { @micropost }
  it { should respond_to(:user_id) }
  it { should respond_to(:content) }
  it { should respond_to(:user) }
  it { should respond_to(:in_reply_to) }
  it { should respond_to(:replies) }
  its(:user) { should == user }
  it { should be_valid }


  describe "accessible attributes" do
    it "should not be able to access user_id attribute" do
      lambda { Micropost.new(content: "BLAH", user_id:  1) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "missing user id" do
    before { @micropost.user_id = nil }

    it { should_not be_valid }
  end

  #Content tests
  describe "when content is not present" do
    before { @micropost.content = nil }
    it { should_not be_valid }
  end

  describe "when content length is greater than 140 characters" do
    before do
      @micropost.content = "a" * 141
    end
      it { should_not be_valid }
  end

  describe "when content is blank" do
    before { @micropost.content = " " }
      it { should_not be_valid }  
  end
end
