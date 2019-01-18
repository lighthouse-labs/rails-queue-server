require 'rails_helper'

describe 'Navbar', type: :feature, js: true do
  context "when the student is logged out" do
    it "has valid links in the navbar" do
      visit root_path
      # save_screenshot
      find_link("Home").click
      expect(page).to have_css("h1", text: "Welcome to Compass")

      visit root_path
      expect(page).to have_link("Sign In")
      find_link("Sign In").click
      expect(page).to have_css("h1", text: "Compass")
      expect(page).to have_text('Log in with GitHub')
    end
  end

  context "when the student is logged in" do
    describe "valid links in the navbar" do
      let(:cohort) { create :cohort }
      let(:student) { create :student, cohort: cohort, uid: GITHUB_OAUTH_HASH['uid'] }
      before :each do
        student
        visit github_session_path
      end

      it 'root should not show "Sign In"' do
        expect(page).to_not have_link("Sign In")
      end

      it 'should properly navigate to Today' do
        find_link("Home").click
        expect(page).to have_css("h1", text: "Schedule")
      end

      it 'should properly navigate to "Schedule"' do
        find_link("Program").click
        find_link("Schedule").click
        expect(page).to have_css("h1", text: "Schedule")
      end

      it 'should properly navigate to "Projects"' do
        find_link("Program").click
        find_link("Projects").click
        expect(page).to have_css("h1", text: "Projects")
      end

      it 'should properly navigate to "Interviews"' do
        find_link("Program").click
        find_link("Interviews").click
        expect(page).to have_css("h1", text: "Interviews")
      end

      it 'should properly navigate to "Classmates"' do
        find_link(student.first_name).click
        find_link("Classmates").click
        expect(page).to have_css("h1", text: cohort.name.to_s)
      end

      it 'should properly navigate to "Teacher"' do
        find_link(student.first_name).click
        find_link("Teachers").click
        expect(page).to have_css("h1", text: "Teachers")
      end

      it 'should properly navigate to "Feedback"' do
        find_link("Feedback").click
        expect(page).to have_css("h3", text: "Pending")
      end

      it 'should properly navigate to "Edit Profile"' do
        find_link(student.first_name).click
        find_link("Edit Profile").click
        expect(page).to have_css("h1", text: "Edit Your Details")
      end
    end
  end
end
