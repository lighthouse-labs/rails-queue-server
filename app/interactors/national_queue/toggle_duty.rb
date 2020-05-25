class NationalQueue::ToggleDuty

  include Interactor::Organizer

  organize  NationalQueue::SmartTaskRequeue,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
