class NationalQueue::UpdateTechInterview

  include Interactor::Organizer

  organize  NationalQueue::UpdateInterviewRecord,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
