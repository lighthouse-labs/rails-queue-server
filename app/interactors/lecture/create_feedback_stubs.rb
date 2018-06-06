class Lecture::CreateFeedbackStubs

  include Interactor

  before do
    @teacher = context.teacher
    @presenter = context.presenter
  end
  
  def call
    cohort.students.each do |student|
      activity.feedbacks.create(student: student, teacher: presenter)
    end
  end

end