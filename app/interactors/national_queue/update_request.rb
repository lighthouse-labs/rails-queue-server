class NationalQueue::UpdateRequest

  include Interactor::Organizer

  organize  NationalQueue::UpdateAssistanceRequest,
            NationalQueue::BroadcastStudentQueueUpdate,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::SmartTaskRoute,
            NationalQueue::BroadcastTeacherQueueUpdate

end
