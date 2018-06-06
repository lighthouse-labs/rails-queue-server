class Lecture::CreateLecture

  include Interactor

  before do
    @activity = context.activity
    @lecture_params = context.lecture_params
    @presenter_name = context.presenter.full_name
  end

  def call
    @lecture = @activity.lectures.new(@lecture_params.merge(day: @activity.day, presenter_name: @presenter_name))

    if @lecture.save
      Lecture::EmailLectureToStudents.call(lecture: @lecture)
    else
      context.fail!(error: @lecture.errors.full_messages.first)
    end
  end

end
