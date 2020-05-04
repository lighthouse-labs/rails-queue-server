class NationalQueue::OffDuty

  include Interactor::Organizer

  organize  NationalQueue::SmartTaskReassignQueue,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
