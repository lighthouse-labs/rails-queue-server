class AssignAsStudentToCohort

  include Interactor

  def call
    @user = context.user
    @user.cohort = context.cohort
    @user.type = 'Student'
    unless @user.save(validate: false)
      context.fail!(error: 'Unexpected Error: Failed to update user')
    end
  end

end
