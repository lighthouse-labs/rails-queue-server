class ZoomMeeting::GetUser

  include Interactor

  before do
    @users = context.users
    @email = context.email.strip.empty? ? context.user['email'] : context.email
  end

  def call
    @users.each do |user|
      next unless @email == user['email']
      context.user = user
      context.update_user_stack ||= []
      context.update_user_stack.push(user: user, license: 2) unless user['type'].to_i == 2
      break
    end
    context.fail!(error: "#{@email} does not have a zoom account with the organization.") unless context.user['pmi']
  end

end
