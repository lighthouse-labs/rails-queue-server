
class ZoomMeeting::PushLicenseRemove

  include Interactor

  before do
    @user = context.user
  end

  def call
    context.update_user_stack ||= []
    context.update_user_stack.push(user: @user, license: 1) if @user
  end

end
