class CompleteTechInterview

  include Interactor::Organizer

  organize  MarkTechInterview,
            CreateOutcomeResultsFromTechInterview,
            RequestQueue::BroadcastUpdateAsyc

end
