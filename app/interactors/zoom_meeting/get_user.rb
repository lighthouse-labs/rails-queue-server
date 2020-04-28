class ZoomMeeting::GetUser

  include Interactor

  before do
    @users = context.users
    @email = context.email
  end

  def call
    @users.each do |user|
      next unless @email == user['email']
      context.user = user
      break
    end
    context.user ||= {}
    context.warnings ||= {}
    context.warnings[:get_user] = "#{@email} does not have a zoom account with the organization." unless context.user['pmi']
  end

end
