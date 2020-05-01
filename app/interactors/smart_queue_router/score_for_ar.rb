class SmartQueueRouter::ScoreForAr

  include Interactor::Organizer

  organize  SmartQueueRouter::RouterSettings,
            SmartQueueRouter::GetOnDutyTeachers,
            SmartQueueRouter::TeacherAvailabilityScore,
            SmartQueueRouter::TeacherLocationScore,
            SmartQueueRouter::TeacherPreviousAssistanceScore
            
end
