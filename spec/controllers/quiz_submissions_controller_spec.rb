require 'rails_helper'

describe QuizSubmissionsController do
  describe "GET 'show'" do
    it "returns http success" do
      pending('logic to determine which quiz submission to show to whom')
      get :show
      expect(response).to be_success
    end
  end
end
