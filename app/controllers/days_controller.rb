class DaysController < ApplicationController

  before_action :ensure_day_schedule_enabled

  include CourseCalendar # concern
  include GithubEducationPack # concern

  def show
    load_day_schedule

    if student?
      # Teachers dont have day feedback associated with their model
      @day_feedback = current_user.day_feedbacks.new
    end
  end

  private

  # Some courses are workbook-only and do not want/need the day schedule enabled.
  # Ideally we should have a better UX where PT courses do have a schedule but one curriculum can be delivered via various schedules. Until we have that, disabling this feature and resorting to simple workbook UX for students and teachers - KV
  def ensure_day_schedule_enabled
    if !@program.has_schedule?
      if @program.settings['default_workbook_slug'].present?
        redirect_to workbook_path(@program.settings['default_workbook_slug'])
      else 
        raise "Configuration Issue: Schedule is disabled and there is no default_workbook_slug specified in the program settings"
      end
    end
  end

end
