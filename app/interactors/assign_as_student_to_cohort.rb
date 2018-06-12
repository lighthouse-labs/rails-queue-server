class AssignAsStudentToCohort

  include Interactor

  before do
    @user = context.user
  end

  def call
    @user.cohort = context.cohort
    @user.type = 'Student'
    context.fail!(error: 'Unexpected Error: Failed to update user') unless @user.save(validate: false)
  end

end
