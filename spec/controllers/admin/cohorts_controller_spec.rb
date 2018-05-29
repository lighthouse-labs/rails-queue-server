require 'rails_helper'

describe Admin::CohortsController do
  before :each do
    admin_user = create(:user, :admin)
    login_as(admin_user)
    @cohorts = create_list(:cohort, 5)
  end

  describe 'GET #index' do
    it 'renders index template' do
      get :index
      expect(response).to render_template :index
    end

    it 'assigns all cohorts to @cohorts' do
      get :index
      expect(assigns(:cohorts)).to match_array(@cohorts)
    end

  end
end
