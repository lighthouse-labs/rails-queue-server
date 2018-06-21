class Evaluations::Complete

  include Interactor::Organizer

  organize  Evaluations::ValidateCompleteness,
            Evaluations::UpdateResult,
            Evaluations::Finish,
            Evaluations::CreateFeedbackStub,
            Evaluations::SendEmail

end
