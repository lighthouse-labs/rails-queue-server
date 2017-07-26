require 'rails_helper'

describe Admin::DashboardController do
  describe 'GET show' do
    describe "security" do
      it "succeeds (http 200) when logged in as an admin" do
        admin_user = create(:user,  :admin)
        login_as(admin_user)
        get :show
        expect(response).to be_success
      end

      it "redirect (http 302) when logged in as a student" do
        student = create(:student)
        login_as(student)
        get :show
        expect(response.code).to eq('302')
      end
    end

    describe "show action" do
      before :each do
        admin_user = create(:user, :admin)
        login_as(admin_user)
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template :show
      end

      it 'renders within the admin layout' do
        get :show
        expect(response).to render_template(layout: 'admin')
      end
    end
  end
end
