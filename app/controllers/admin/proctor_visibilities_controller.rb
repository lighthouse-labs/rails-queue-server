class Admin::ProctorVisibilitiesController < Admin::BaseController

  before_action :set_user
  before_action :check_permission

  def create
    @user.can_view_programming_tests = true

    if @user.save
      redirect_to :back, notice: "#{@user.full_name} can now view programming tests!"
    else
      redirect_to :back, alert: "#{@user.full_name} failed to be able to view programming tests! Now what?"
    end
  end

  def destroy
    @user.can_view_programming_tests = false

    if @user.save
      redirect_to :back, notice: "#{@user.full_name} can no longer view programming tests!"
    else
      redirect_to :back, alert: "Admin privileges for #{@user.full_name} failed to be revoke ability to view programming tests! Now what?"
    end
  end

  private

  def set_user
    @user = User.find params[:user_id]
  end

  def check_permission
    redirect_to :back, alert: 'Not Allowed, Champ.' unless current_user.can_allow_view_programming_tests?
  end

end
