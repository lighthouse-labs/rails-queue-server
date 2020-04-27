class TechInterview::UpdateInterviewRecord

  include Interactor

  before do
    @tech_interview = TechInterview.find_by id: context.options[:tech_interview_id]
    @options = context.options
    @interviewer = context.interviewer
  end

  def call
    context.updates ||= []

    case @options[:type]
    when 'cancel_interview'
      context.fail! unless @interviewer.admin? || @tech_interview.interviewer == @interviewer

      context.assistor = @tech_interview.interviewer
      @tech_interview.started_at = nil
      context.interview_results = TechInterviewResult.where(tech_interview_id: @tech_interview.id)
      context.interview_results.delete_all
      context.tech_interview = @tech_interview
      success = @tech_interview.save
    when 'complete_interview'
    end

    context.fail! unless success
  end

  def rollback
    case @options[:type]
    when 'cancel_interview'
      contex.interview_results.each do |interview_result|
        TechInterviewResult.new(interview_result.attributes_hash).save
      end
    when 'complete_interview'
      # add when interview creation is moved to this interactor
    end
  end

end
