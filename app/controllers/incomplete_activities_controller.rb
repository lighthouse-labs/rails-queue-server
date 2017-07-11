class IncompleteActivitiesController < ApplicationController

  before_action :student_required

  def index
    @activities = current_user.incomplete_activities
    @incomplete_and_stretch = @activities.stretch
  end

  private

  def student_required
    redirect_to(:root, alert: 'You are not a student') unless student?
  end

end
