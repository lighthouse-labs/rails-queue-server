class AssignAsStudentToCohort

  include Interactor

  def call
    @user = context.user
    @user.cohort = context.cohort
    @user.type = 'Student'
    @user.save!(validate: false)
  end

end
