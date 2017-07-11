class Admin::ProjectsController < Admin::BaseController

  before_action :find_project, only: [:edit, :update, :destroy]

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to project_path(@project), notice: "#{@project.name} created."
    else
      render :new, notice: @project.errors
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      render :new
    end
  end

  def destroy
    if @project.destroy
      redirect_to projects_path, notice: "#{@project.name} deleted."
    else
      redirect_to projects_path, notice: "#{@project.name} not deleted."
    end
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end

end
