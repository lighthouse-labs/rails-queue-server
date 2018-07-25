class Lecture::CreateLecture

  include Interactor

  before do
    @activity = context.activity
    @lecture_params = context.lecture_params
  end

  def call
    context.lecture = @lecture = @activity.lectures.new(@lecture_params)
    @lecture.day = @activity.day

    context.fail!(error: @lecture.errors.full_messages.first) unless @lecture.save
  end

end
