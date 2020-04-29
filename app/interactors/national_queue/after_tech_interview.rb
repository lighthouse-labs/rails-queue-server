class NationalQueue::AfterTechInterview

  include Interactor

  before do
    @tech_interview = context.tech_interview
    @interviewer = context.interviewer
  end

  def call
    context.assistor = @interviewer
    context.updates ||= []
    context.updates.push({ task: @tech_interview, shared: true })
  end

end
