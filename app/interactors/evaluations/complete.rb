class Evaluations::Complete

  include Interactor::Organizer

  organize  Evaluations::ValidateCompleteness,
            Evaluations::UpdateResult,
            Evaluations::Finish,
            RequestQueue::BroadcastUpdateAsync,
            Evaluations::CreateFeedbackStub,
            Evaluations::SendEmail

end
