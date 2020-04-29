class NationalQueue::ProvideAssistance

  include Interactor::Organizer

  organize  NationalQueue::CreateAssistance,
            NationalQueue::BroadcastTeacherQueueUpdate

end
