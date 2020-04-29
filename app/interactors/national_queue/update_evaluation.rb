class NationalQueue::UpdateEvaluation

  include Interactor::Organizer

  organize  NationalQueue::UpdateEvaluationRecord,
            NationalQueue::BroadcastTeacherAvailability,
            NationalQueue::BroadcastTeacherQueueUpdate

end
