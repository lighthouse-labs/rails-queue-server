class AssignAsStudentToCohort

  include Interactor

  def call
    context.user.cohort = context.cohort
    context.user.type = 'Student'
    context.user.save!(validate: false)
  end

end
