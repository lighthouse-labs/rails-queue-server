class ProjectsController < ApplicationController

  before_action :find_project, only: [:show]

  def index
    @projects = Project.active.core
    @stretch_projects = Project.active.stretch
  end

  def show; end

  private

  def find_project
    @project = Project.find_by!(slug: params[:id])
  end

end
