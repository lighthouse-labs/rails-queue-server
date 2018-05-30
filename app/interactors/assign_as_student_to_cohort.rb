class AssignAsStudentToCohort

  include Interactor

  before do
    @user = context.user
  end

  def call
    @user.cohort = context.cohort
    @user.type = 'Student'
    unless @user.save(validate: false)
      context.fail!(error: 'Unexpected Error: Failed to update user')
    end
  end

end
