class ZoomMeeting::GetUser

  include Interactor

  before do
    @users = context.users
    @user = context.user
  end

  def call
    @users.each do |user|
      next unless @user['email'] == user['email']
      context.user = user
      context.update_user_stack ||= []
      context.update_user_stack.push(user: user, license: 2)
      break
    end
    context.fail!(error: 'You do not have a zoom account with the organization.') unless context.user['pmi']
  end

end
