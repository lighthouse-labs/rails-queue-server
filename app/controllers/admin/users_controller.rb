class Admin::UsersController < Admin::BaseController

  before_action :load_user, only: [:reactivate, :deactivate]

  def index
    @users = User.all
  end

  def reactivate
    @user.reactivate!
    render nothing: true
  end

  def deactivate
    @user.deactivate!
    render nothing: true
  end

  private

  def load_student
    @user = User.find(params[:id])
  end

end