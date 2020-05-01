class TechInterview::CreateTechInterview

  include Interactor::Organizer

  organize  TechInterview::CreateInterviewRecord,
            TechInterview::CreateResults

end
