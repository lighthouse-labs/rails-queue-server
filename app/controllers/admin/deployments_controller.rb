class Admin::DeploymentsController < Admin::BaseController

  def index
    @deployments = Deployment.all
    @deployments = @deployments.page(params[:page])
  end

  def new
    @repository = @program.content_repositories.first
    @deployment = Deployment.new(
      content_repository: @repository,
      branch:             ENV['CURRICULUM_BRANCH'] || 'master'
    )
  end

  def create
    @repository = @program.content_repositories.find params[:deployment][:content_repository_id]
    @branch = params[:deployment][:branch]
    @sha = params[:deployment][:sha]
    @program = @repository.program

    CurriculumDeploymentWorker.perform_async(@repository.id, @branch, @sha)

    redirect_to [:admin, :deployments], notice: "Deployment Queued (#{@branch} branch) for #{@program.name}! Refresh to view it"
  end

end
