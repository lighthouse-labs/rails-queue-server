class NationalQueue::OnDuty

  include Interactor::Organizer

  organize  NationalQueue::SmartTaskAssignQueue,
            NationalQueue::BroadcastTeacherQueueUpdate

end
