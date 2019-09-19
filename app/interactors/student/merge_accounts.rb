class Student::MergeAccounts

  include Interactor

  before do
    @from = context.from_account
    @to   = context.to_account
  end

  def call
    fields = {
      ActivitySubmission    => :user_id,
      ActivityFeedback      => :user_id,
      ActivityAnswer        => :user_id,
      AssistanceRequest     => :requestor_id,
      Assistance            => :assistee_id,
      DayFeedback           => :user_id,
      Evaluation            => :student_id,
      Feedback              => :student_id,
      OutcomeResult         => :user_id,
      PrepAssistanceRequest => :user_id,
      QuizSubmission        => :user_id,
      TechInterview         => :interviewee_id
    }

    fields.each do |model, attribute|
      model.where(attribute => @from.id).update_all(attribute => @to.id)
    end
  end

  end
