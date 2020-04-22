class NationalQueue::UpdateInterviewRecord
  include Interactor

  before do
    @interview = TechInterview.find_by id: context.options[:tech_interview_id]
    @options = context.options
    @assistor = context.assistor
  end

  def call
    context.updates ||= []
    
    case @options[:type]
    when 'cancel_interview'
      context.assistor = @interview.interviewer

      # FIXME: Doesn't do a permission check using @user
      #        And also should be in a db transaction
      #        See StartTechInterview interactor/service-obj for eg
      #        - KV
      @interview.started_at = nil
      TechInterviewResult.where(tech_interview_id: @interview.id).delete_all

      context.updates.push({task: @interview, shared: true}) if success = @interview.save
    when 'start_interview'
      context.updates.push({task: @interview, shared: true})
      success = true
    end

    context.fail! unless success
  end
end
