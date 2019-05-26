class DaysController < ApplicationController

  include CourseCalendar # concern
  include GithubEducationPack # concern

  def show
    load_day_schedule

    if student?
      # Teachers dont have day feedback associated with their model
      @day_feedback = current_user.day_feedbacks.new
    end
  end

end
