class DaysController < ApplicationController

  include CourseCalendar # concern

  def show
    @activities = Activity.chronological.active.for_day(day)

    @project = Project.where("? between start_day AND end_day", day.to_s).first

    @outcomes = @activities.flat_map { |activity| activity.outcomes }.uniq

    if student?
      # Teachers dont have day feedback associated with their model
      @day_feedback = current_user.day_feedbacks.new
    end
  end

end