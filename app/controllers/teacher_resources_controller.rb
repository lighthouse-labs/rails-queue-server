class TeacherResourcesController < ApplicationController

  def show
    redirect_to_first_activity
  end

  def index
    redirect_to_first_activity
  end

  private

  def redirect_to_first_activity
    @section = params[:id].present? ? TeacherSection.find_by!(slug: params[:id]) : TeacherSection.first
    @activity = @section.activities.chronological.active.first if @section
    if @activity
      redirect_to teacher_resource_activity_path(@section, @activity)
    else
      redirect_to :root, alert: 'Sorry, no teacher-spefific content available yet.'
    end
  end

end
