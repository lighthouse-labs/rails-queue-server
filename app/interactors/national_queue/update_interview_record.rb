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
      context.fail! unless @assistor.admin? || @interview.interviewer == @assistor

      context.assistor = @interview.interviewer
      @interview.started_at = nil
      context.interview_results = TechInterviewResult.where(tech_interview_id: @interview.id)
      context.interview_results.delete_all
      context.updates.push({ task: @interview, shared: true }) if success = @interview.save
    when 'start_interview'
      context.updates.push({ task: @interview, shared: true })
      success = true
    end

    context.fail! unless success
  end

  def rollback
    case @options[:type]
    when 'cancel_interview'
      contex.interview_results.each do |interview_result|
        TechInterviewResult.new(interview_result.attributes_hash).save
      end
    when 'start_interview'
      # add when interview creation is moved to this interactor
    end
  end

end
