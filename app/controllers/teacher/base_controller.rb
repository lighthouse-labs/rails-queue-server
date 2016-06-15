class Teacher::BaseController < ApplicationController

  before_filter :teacher_required

  private

  def teacher_required
    redirect_to(:root, alert: 'Access Not Allowed') unless teacher?
  end

end
