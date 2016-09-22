class AssessmentTestsController < ApplicationController

  before_filter :only_teachers


  private

  def only_teachers
    unless teacher?
      redirect_to :root, alert: 'Access not allowed.'
    end
  end

end
