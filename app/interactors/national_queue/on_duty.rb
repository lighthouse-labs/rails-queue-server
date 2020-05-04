class NationalQueue::OnDuty

  include Interactor::Organizer

  organize  NationalQueue::SmartTaskAssignQueue,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
