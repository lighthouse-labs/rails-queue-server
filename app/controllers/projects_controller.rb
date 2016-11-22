class ProjectsController < ApplicationController
  before_action :find_project, only: [:show]

  def index
    @projects = Project.all
  end

  def show
    @projects = find_project
    #@feedbacks = ActivityFeedback.filter_by(:evals).reorder(order)
    #@evaluations = cohort.students.joins("JOIN evaluations ON evaluations.student_id = users.id").order(created_at: :desc).take(1)
    @evaluations = Evaluation.filter_by(params, cohort)
    # @ids.each do |id|
    #   @evaluations.push(Evaluation.where(id: id))
    # end

    ##make the class method return the IDs, then do a regular where query on the controller using the IDs
  end

  private

  def find_project
    @project = Project.find_by!(slug: params[:id])
  end

end
