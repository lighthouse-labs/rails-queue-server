# This is definitely an overkill test.

require 'spec_helper'

describe 'Authentication' do

  context "with new user profile" do
    it 'creates a user record based on Github OAuth Response Hash' do
      FactoryGirl.create :user # => 1
      visit github_session_path
      expect(User.count).to eq(2)
    end

    it "defaults the user information based on Github" do
      visit github_session_path
      user = User.last
      expect(user.first_name).to eq('Khurram')
      expect(user.last_name).to eq('Virani')
      expect(user.github_username).to eq('kvirani')
      expect(user.email).to eq('kvirani@lighthouselabs.ca')
      expect(user.uid).to eq('uid')
      expect(user.token).to eq('token')
    end

    it "redirects to profile edit page" do
      visit github_session_path
      expect(current_path).to eq(edit_profile_path)
    end
  end

  context "with existing registered user" do
    let!(:user) { FactoryGirl.create :user_for_auth }

    it "does not create a new user record" do
      pending('breaks because it redirects to first prep activitity route, and we have not created any activities')
      visit github_session_path
      expect(User.count).to eq(1) # was already 1 due to FG.create above
    end

    # Should redirect to prep page when completed registration but prepping (not assigned type to Student/Teacher)
    it "redirects to prep page (instead of registration page) if prepping" do
      pending('breaks because it redirects to first prep activitity route, and we have not created any activities')
      visit github_session_path
      expect(current_path).to eq(prep_index_path)
    end
  end

  context "with existing unregistered user" do
    let!(:user) { FactoryGirl.create :unregistered_user, uid: "uid", token: "token" }
    pending('-- In the current implementation, unregistered users skip activerecord validation, FactoryGirl cannot do this')

    xit "does not create a new user record" do
      visit github_session_path
      expect(User.count).to eq(1) # was already 1 due to FG.create above
    end

    xit "redirects to profile edit page" do
      visit github_session_path
      expect(current_path).to eq(edit_profile_path) # was already 1 due to FG.create above
    end

  end

end
