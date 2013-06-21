require 'spec_helper'

describe Relationship do
  let(:follower) { FactoryGirl.create :user }  
  let(:followed) { FactoryGirl.create :user }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) } #don't like the way it's being called
  let(:reverse_relationship) { followed.relationships.build(followed_id: follower.id) } #don't like the way it's being called

  subject{ relationship } # had problems here. Need to check how to get what the "it" is refering too

  it { should be_valid}

  describe "accessible attributes" do
    it "should not allow access to follower_id" do
      expect{ Relationship.new(follower_id: follower.id) }
      .to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    # WHAT IS THIS!? CoNfuSeD!
    its(:follower) { should == follower }
    its(:followed) { should == followed }
  end

  describe "when followed_id is not present" do
    before { relationship.followed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower_id is not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end

  describe "when relationship removed for user" do
    before do
      relationship.save 
      reverse_relationship.save
    end

    it "should have all relationships for the user removed" do
      relationships = follower.relationships.dup
      reverse_relationships = follower.reverse_relationships.dup
      #delete the user. All relations in the table should not exist
      follower.destroy

      relationships.each do |r|
        Relationship.find_by_id(r.id).should be_nil
      end

      reverse_relationships.each do |r|
        Relationship.find_by_id(r.id).should be_nil
      end
    end
  end
end
