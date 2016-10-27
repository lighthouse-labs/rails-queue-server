class Admin::UsersController < Admin::BaseController

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

end