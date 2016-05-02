class ProjectsController < ApplicationController
  before_action :find_project, only: [:show]
  def index
    @projects = Project.all
  end
  def show
  end
end
