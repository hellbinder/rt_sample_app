require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| Home' }


    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }
      let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet") }
      let!(:micropost_reply) { FactoryGirl.create :micropost, user: other_user, in_reply_to: m1.id, content: "reply of this other post" }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        sign_in user
        visit root_path
      end

      describe "micropost header count" do

        it "should have header pluralized" do
          page.should have_selector("span", text: "microposts")
        end

        describe "singular post" do
          before do
            user.microposts.first.destroy
            visit root_url
          end
          it "should have header singular" do
            page.should have_selector("span", text: "micropost")
          end
        end
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
          page.should have_link("delete", href: micropost_path(item) )
        end
      end

      it "should render the micropost reply" do
        print m1.replies.count
        m1.replies.each do |reply|
          page.should have_selector("span.content", text: "#{reply.content}")
        end
      end

      describe "following/follower counts" do
        let(:other_user) { FactoryGirl.create :user }
        before do
          other_user.follow!(user)
          visit root_path #user should be signed in already
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 follower", href: followers_user_path(user)) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About' }
    let(:page_title) { 'About' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"

  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end
end