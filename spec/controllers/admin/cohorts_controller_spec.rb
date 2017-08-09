require 'rails_helper'

describe Admin::CohortsController do
  before :each do
    admin_user = create(:user, :admin)
    login_as(admin_user)
  end

  describe 'GET #index' do
    it 'assigns all cohorts to @cohorts minus active cohort' do
      cohorts = create_list(:cohort, 5)
      get :index
      expect(assigns(:cohorts)).to match_array(cohorts)
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template :index
    end
  end
end
