class Evaluations::Complete

  include Interactor::Organizer

  organize  Evaluations::ValidateCompleteness,
            Evaluations::UpdateResult,
            Evaluations::Finish,
            Evaluations::SendEmail,
            Evaluations::CreateFeedbackStub

end
