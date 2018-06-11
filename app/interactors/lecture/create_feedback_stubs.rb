class Lecture::CreateFeedbackStubs

  include Interactor

  before do
    @presenter = context.presenter
    @cohort = context.lecture.cohort
    @activity = context.lecture.activity
  end
  
  def call
    @cohort.students.each do |student|
      @activity.feedbacks.create(student: student, teacher: @presenter)
    end
  end

end