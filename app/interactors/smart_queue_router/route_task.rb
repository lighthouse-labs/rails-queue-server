class SmartQueueRouter::RouteTask

  include Interactor::Organizer

  organize  SmartQueueRouter::RouterSettings,
            SmartQueueRouter::GetOnDutyTeachers,
            SmartQueueRouter::TeacherAvailabilityScore,
            SmartQueueRouter::TeacherLocationScore,
            SmartQueueRouter::TeacherPreviousAssistanceScore,
            SmartQueueRouter::AssignTask

end