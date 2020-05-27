class SmartQueueRouter::ScoreForAr

  include Interactor::Organizer

  organize  SmartQueueRouter::RouterSettings,
            SmartQueueRouter::GetOnDutyTeachers,
            SmartQueueRouter::TeacherAvailabilityScore,
            SmartQueueRouter::TeacherMaxQueueScore,
            SmartQueueRouter::TeacherAverageRatingScore,
            SmartQueueRouter::TeacherPreviousAssistanceScore,
            SmartQueueRouter::TeacherTagScore,
            SmartQueueRouter::TeacherLocationScore

end
