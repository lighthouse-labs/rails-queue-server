class NationalQueue::CreateTechInterview

  include Interactor::Organizer

  organize  TechInterview::CreateTechInterview,
            NationalQueue::AfterTechInterview,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
