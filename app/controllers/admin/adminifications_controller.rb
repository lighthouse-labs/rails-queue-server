class Admin::AdminificationsController < Admin::BaseController

  before_action :require_user
  before_action :check_permission

  def create
    @user.admin = true
    if @user.save
      redirect_to :back, notice: "#{@user.full_name} is now an admin!"
    else
      redirect_to :back, alert: "#{@user.full_name} failed to become an admin! Now what?"
    end
  end

  def destroy
    @user.admin = false
    if @user.save
      redirect_to :back, notice: "#{@user.full_name} is no longer an admin!"
    else
      redirect_to :back, alert: "Admin privileges for #{@user.full_name} failed to be revoked! Now what?"
    end
  end

  private

  def require_user
    @user = User.find params[:user_id]
  end

  def check_permission
    redirect_to :back, alert: 'Not Allowed, Champ.' unless current_user.can_adminify?(@user)
  end

end
