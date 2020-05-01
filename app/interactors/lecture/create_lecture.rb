class Lecture::CreateLecture

  include Interactor

  before do
    @activity = context.activity
    @workbook = context.workbook # optional
    @lecture_params = context.lecture_params
  end

  def call
    context.lecture = @lecture = @activity.lectures.new(@lecture_params)
    @lecture.day = @activity.day
    @lecture.workbook = @workbook

    context.fail!(error: @lecture.errors.full_messages.first) unless @lecture.save
  end

end
