class Teacher::BaseController < ApplicationController
  before_filter :teacher_required

  private

  def admin_required
    unless teacher?
      flash[:alert] = 'Access Not Allowed'
      redirect_to :root
    end
  end
end
