class AssessmentTestsController < ApplicationController

  before_action :only_teachers

  private

  def only_teachers
    redirect_to :root, alert: 'Access not allowed.' unless teacher?
  end

end
