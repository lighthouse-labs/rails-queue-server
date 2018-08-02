class Lecture::Complete

  include Interactor::Organizer

  organize  Lecture::CreateLecture,
            Lecture::EmailLectureToStudents,
            Lecture::CreateFeedbackStubs

end
