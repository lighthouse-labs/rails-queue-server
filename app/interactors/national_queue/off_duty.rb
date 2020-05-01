class NationalQueue::OffDuty

  include Interactor::Organizer

  organize  NationalQueue::SmartTaskReassignQueue,
            NationalQueue::BroadcastTeacherQueueUpdate

end
