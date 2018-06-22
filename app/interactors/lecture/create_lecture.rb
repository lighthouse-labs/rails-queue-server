class Lecture::CreateLecture

  include Interactor

  before do
    @activity = context.activity
    @lecture_params = context.lecture_params
  end

  def call
    day = @activity.day
    @lecture = @activity.lectures.new(@lecture_params.merge(day: day))

    if @lecture.save
      context.lecture = @lecture
    else
      context.fail!(error: @lecture.errors.full_messages.first)
    end
  end

end
