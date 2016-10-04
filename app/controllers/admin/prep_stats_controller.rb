class Admin::PrepStatsController < ApplicationController

  DEFAULT_PER = 10

  def index
    @users = User.all
    @users = @users.where(id: params[:user_id]) if params[:user_id]
    @users = @users.page(params[:page]).per(DEFAULT_PER)
  end

end
