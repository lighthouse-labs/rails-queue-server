class SmartQueueRouter::TeacherSkillsScore
  include Interactor

  before do
    @teachers = context.teachers
  end

  def call
    # tba when skills are added
  end

end
