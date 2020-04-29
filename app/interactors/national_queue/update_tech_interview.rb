class NationalQueue::UpdateTechInterview

  include Interactor::Organizer

  organize  TechInterview::UpdateInterviewRecord,
            NationalQueue::AfterTechInterview,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
