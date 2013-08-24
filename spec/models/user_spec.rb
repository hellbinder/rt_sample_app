# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  before { @user = User.new(name: "Example User", username:"uexample", email: "user@example.com",
    password: "foobar", password_confirmation: "foobar") }
  subject { @user }
  it { should respond_to(:username) }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:admin) }
  it { should respond_to(:remember_token) } #since its using cookies (not sessions) to remember user
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:follow!) }
  it { should respond_to(:following?) }
  it { should respond_to(:active) }
  it { should respond_to(:confirmation_hash) }
  #done a little differently since its checking for the class method, not instance
  it 'should respond to ::bar' do
    User.should respond_to(:search)
  end
  it { should_not allow_mass_assignment_of(:admin) }
  it { should_not allow_mass_assignment_of(:active) }
  it { should_not allow_mass_assignment_of(:confirmation_hash) }

  it { should be_valid }
  it { should_not be_admin }

#make sure that it's admin when toggled.
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin } #implies (via the RSpec boolean convention) that the user should have an admin? boolean method.
  end

  describe "default fields" do
    before {@user.save}
    its(:remember_token) { should_not be_blank }
    it { puts @user.active? }
    it { should_not be_active }
    its(:confirmation_hash) { should_not be_blank } #When creating user, it should create new hash for confirmation
  end

  #Password  Tests
  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end

    describe "with a password that's too short" do
      before { @user.password = @user.password_confirmation = "m" * 5}
      it { should_not be_valid }
    end
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "yomomma"}
    it { should_not be_valid }
  end

  #Name Tests
  describe "when name is not present" do
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "m" * 51}
    it { should_not be_valid }
  end

#User Name Tests
  describe "when username is not present" do
    before { @user.username = "" }
    it { should_not be_valid }
  end

  describe "when name is present" do
    before { @user.username = "hellbinder" }
    it { should be_valid }
  end

  describe "when username is too long" do
    before { @user.username = "m" * 16}
    it { should_not be_valid }
  end

  describe "when username is too short" do
    before { @user.username = "m" * 5}
    it { should_not be_valid }
  end

  describe "when user name is already taken" do
    before do
      user_with_same_username= @user.dup
      user_with_same_username.username = @user.username
      user_with_same_username.save
    end
    it {should_not be_valid}
  end

  #Email Tests
  describe "when user email is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. 
        foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when user email is valid" do
    it "should be valid" do
      addresses = %w[user@foo.com A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when user email is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it {should_not be_valid}
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "micropost associations" do
    before { @user.save }  
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    it "should have the right microposts in the right order" do
      #@user.microposts.should == [newer_micropost, older_micropost] #testing order by using array.
      #I think the following can also be used
      @user.microposts.index(newer_micropost).should == 0
    end

    it "destroy associated microposts" do
      microposts = @user.microposts.dup
      @user.destroy
      microposts.should_not be_empty #make sure dup is used
      microposts.each do |mp|
        Micropost.all.should_not include mp
      end
    end

    describe "status" do
      let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
      let(:followed_user) { FactoryGirl.create :user }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "This is a test")}
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      #the followed users micropost should also appear
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create :user }
    before do
      @user.save()
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do #Had issues in here becuase of the order. GOTS TO WATCH OUT FOR ORDER
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
