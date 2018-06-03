class Admin::PrepStatsController < Admin::BaseController

  DEFAULT_PER = 5

  def index
    @users = User.active.order(id: :desc)
    @users = @users.by_keywords(params[:keywords]) if params[:keywords].present?
    @users = @users.page(params[:page]).per(DEFAULT_PER)
    @milestones = Activity.active.prep.milestone.chronological_for_project
    @milestone_count = @milestones.count
  end

end
