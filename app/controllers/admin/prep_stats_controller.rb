class Admin::PrepStatsController < ApplicationController

  DEFAULT_PER = 5

  def index
    @users = User.active.order(id: :desc)
    @users = @users.by_keywords(params[:keywords]) if params[:keywords].present?
    @users = @users.page(params[:page]).per(DEFAULT_PER)
  end

end
