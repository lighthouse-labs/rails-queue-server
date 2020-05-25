class NationalQueue::ProvideFeedback

  include Interactor::Organizer

  organize  NationalQueue::CreateFeedback,
            NationalQueue::BroadcastFeedbackQueueUpdate

end
