require 'spec_helper'

#Using the application helper instead of having to use another helper method for specs.
#This is included in the actual rspec helper method (in the utilities).
describe ApplicationHelper do
  describe "full title" do
    it "should include the page title" do
      full_title('foo').should =~ /foo/
    end
    it "should include the base title" do
      full_title("foo").should =~ /^Ruby on Rails Tutorial Sample App/
    end

    it "should not include a bar for the home page" do
      full_title("").should_not =~ /\|/
    end
  end
end