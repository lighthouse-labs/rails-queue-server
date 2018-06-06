class Lecture::EmailLectureToStudents

  include Interactor

  before do
    @lecture = context.lecture
  end
  
  def call
    UserMailer.new_lecture(@lecture).deliver
  end

end
