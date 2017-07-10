require 'rails_helper'

describe 'Navbar' do
  context "when the student is logged out" do
    it "has valid links in the navbar" do
      visit root_url
      find_link("Home").click
      page.should have_css("h1", :text => "Welcome to Compass")

      visit root_url
      page.should have_link("Sign In")
      find_link("Sign In").click
      page.should have_css("h1", :text => "Login")
    end
  end

  context "when the student is logged in" do
    describe "valid links in the navbar" do
      before :each do
        @cohort = FactoryGirl.create :cohort

        # We need to create a student logged in
        FactoryGirl.create :student, cohort: @cohort, uid: GITHUB_OAUTH_HASH['uid']
        visit github_session_path
      end

      it 'root should not show "Sign In"' do
        page.should_not have_link("Sign In")
      end

      it 'should properly navigate to "Home"' do
        find_link("Home").click
        page.should have_css("h1", :text => "Welcome to Compass")
      end

      it 'should properly navigate to "Schedule"' do
        find_link("Schedule").click
        page.should have_css("h1", :text => "Schedule")
      end

      it 'should properly navigate to "Projects"' do
        find_link("Projects").click
        page.should have_css("h1", :text => "Projects")
      end

      it 'should properly navigate to "Interviews"' do
        find_link("Interviews").click
        page.should have_css("h1", :text => "Interviews")
      end

      it 'should properly navigate to "Classmates"' do
        find_link("Classmates").click
        page.should have_css("h1", :text => "#{@cohort.name}")
      end

      it 'should properly navigate to "Teacher"' do
        find_link("Teacher").click
        page.should have_css("h1", :text => "Teacher")
      end

      it 'should properly navigate to "Feedbacks"' do
        find_link("Feedback").click
        page.should have_css("h3", :text => "Pending")
      end

      it 'should properly navigate to "Edit Profile"' do
        find_link("Edit Profile").click
        page.should have_css("h1", :text => "Edit Your Details")
      end

    end
  end
end
