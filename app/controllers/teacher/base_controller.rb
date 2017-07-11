class Teacher::BaseController < ApplicationController

  before_action :teacher_required

  private

  def teacher_required
    redirect_to(:root, alert: 'Access Not Allowed') unless teacher?
  end

end
