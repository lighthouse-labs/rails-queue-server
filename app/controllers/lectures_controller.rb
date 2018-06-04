class LecturesController < ApplicationController

  # implement before_action to make sure this is locked if the student isn't on the day yet
  # DRY the code with before_action to load @activity and @lecture for the routes that need them

  include CourseCalendar

  def show
    @activity = Activity.find(params[:activity_id])
    @lecture = Lecture.find(params[:id])
    # @day = CurriculumDay.new(@lecture.day, @lecture.cohort)
  end

end