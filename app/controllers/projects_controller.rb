class ProjectsController < ApplicationController

  before_action :find_project, only: [:show]

  include CourseCalendar # concern

  def index
    @projects = Project.active.core
    @stretch_projects = Project.active.stretch
  end

  def show
    load_day_schedule if params[:day_number]
  end

  private

  def find_project
    @project = Project.find_by!(slug: params[:id])
  end

end
