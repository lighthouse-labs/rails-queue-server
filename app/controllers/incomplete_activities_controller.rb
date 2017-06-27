class IncompleteActivitiesController < ApplicationController

  before_filter :student_required

  def index
    @activities = current_user.incomplete_activities
    @incomplete_and_not_stretch = @activities.where(stretch: nil).count
    @incomplete_and_stretch = @activities.count(:stretch);
  end

  private

  def student_required
    redirect_to(:root, alert: 'You are not a student') unless student?
  end

end