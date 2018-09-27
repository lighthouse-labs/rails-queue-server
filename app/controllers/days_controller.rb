class DaysController < ApplicationController

  include CourseCalendar # concern

  def show
    @activities = Activity.chronological.active.for_day(day).includes(:outcomes)

    @workbooks = Workbook.active.unlocks_on_day(day)
    @project = Project.active.core.where("? between start_day AND end_day", day.to_s).first
    @stretch_project = Project.active.stretch.where("? between start_day AND end_day", day.to_s).first

    @interview_template = TechInterviewTemplate.active.where(week: week).first

    # @outcomes = @activities.flat_map(&:outcomes).uniq

    if student?
      # Teachers dont have day feedback associated with their model
      @day_feedback = current_user.day_feedbacks.new
    end
  end

end
