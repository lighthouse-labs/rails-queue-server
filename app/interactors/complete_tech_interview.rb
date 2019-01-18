class CompleteTechInterview

  include Interactor::Organizer

  organize  MarkTechInterview,
            CreateOutcomeResultsFromTechInterview,
            RequestQueue::BroadcastUpdateAsync

end
