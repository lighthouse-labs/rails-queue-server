class SmartQueueRouter::RouteTask

  include Interactor::Organizer

  organize  SmartQueueRouter::RouterSettings,
            SmartQueueRouter::GetOnDutyTeachers,
            SmartQueueRouter::TeacherAvailabilityScore,
            SmartQueueRouter::TeacherMaxQueueScore,
            SmartQueueRouter::TeacherAverageRatingScore,
            SmartQueueRouter::TeacherPreviousAssistanceScore,
            SmartQueueRouter::TeacherLocationScore,
            SmartQueueRouter::AssignTask

end
