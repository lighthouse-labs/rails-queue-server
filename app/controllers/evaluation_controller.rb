class EvaluationController < ApplicationController
  before_action :find_project, only: [:create]
  def index
  end

  def show
  end

  def new
    @evaluation = Evaluation.new
  end

  def create
  end

  def edit
  end

  def update
  end

  private

  def find_project
    @project = Project.find_by(slug: params[:project_id])
  end
end
