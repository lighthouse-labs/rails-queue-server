class NationalQueue::RequestAssistance

  include Interactor::Organizer

  organize  NationalQueue::CreateAssistanceRequest,
            NationalQueue::BroadcastStudentQueueUpdate,
            NationalQueue::SmartTaskRoute,
            NationalQueue::BroadcastTeacherQueueUpdates

end
