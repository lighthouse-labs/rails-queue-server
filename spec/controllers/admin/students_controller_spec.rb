require 'rails_helper'

describe Admin::StudentsController do
  before :each do
    admin_user = create(:user, :admin)
    login_as(admin_user)
  end

  describe 'GET #index' do
    it 'assigns all students to @students' do
      students = create_list(:student, 5)
      get :index
      expect(assigns(:students)).to match_array(students)
    end

    it 'renders index template' do
      students = create_list(:student, 5)
      get :index
      expect(response).to render_template :index
    end
  end
end
