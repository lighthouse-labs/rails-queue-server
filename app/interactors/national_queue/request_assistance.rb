class NationalQueue::RequestAssistance

  include Interactor::Organizer

  organize  NationalQueue::CreateAssistanceRequest,
            NationalQueue::SmartTaskRoute,
            NationalQueue::BroadcastStudentQueueUpdate,
            NationalQueue::BroadcastTeacherQueueUpdate

end
