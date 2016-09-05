class TechInterviewsController < ApplicationController

  before_filter :require_template, only: [:new, :create]
  before_filter :require_interviewee, only: [:new, :create]

  before_filter :require_interview, only: [:edit, :update, :confirm, :complete, :show]
  before_filter :only_incomplete, only: [:edit, :update, :confirm, :complete]

  # Show page not allowed for students, only teachers/admins
  # students view tech_interview_templates#show for their interview status/results
  before_filter :not_for_students, only: [:show]

  def show

  end

  def new
    @tech_interview = TechInterview.new(interviewee: @interviewee)
  end

  def create
    @tech_interview = @interview_template.pending_interview_for(@interviewee) ||
      @interview_template.tech_interviews.new(interviewee: @interviewee)

    result = StartTechInterview(
      tech_interview: @tech_interview,
      interviewer:    current_user
    )

    # should not fail, throw 500 / unexpected error if so
    if result.success?
      redirect_to edit_tech_interview_path(@tech_interview)
    else
      raise result.error
    end


  end

  def edit
  end

  def update
    if @tech_interview.update(interview_params)
      redirect_to confirm_tech_interview_path(@tech_interview)
    else
      raise @tech_interview.results.inspect
      render :edit
    end
  end

  # GET (final step form)
  def confirm
  end

  # PUT (final step submission)
  def complete
    result = CompleteTechInterview.call(
      params: params,
      tech_interview: @tech_interview,
      interviewer: current_user
    )

    if @tech_interview.save
      redirect_to @tech_interview, notice: "Interview completed. Student e-mailed with feedback."
    else
      render :edit
    end
  end

  private

  def require_template
    @interview_template = TechInterviewTemplate.find params[:tech_interview_template_id]

  end

  def require_interviewee
    @interviewee = User.find params[:interviewee_id]
  end

  def require_interview
    @tech_interview = TechInterview.find params[:id]
    @interview_template ||= @tech_interview.tech_interview_template
    @questions = @interview_template.questions
  end

  def only_incomplete
    if @tech_interview.completed?
      redirect_to @tech_interview, alert: 'Already Completed!'
    end
  end

  def not_for_students
    redirect_to(:tech_interview_templates) unless teacher? || admin?
  end

  def interview_params
    params.require(:tech_interview).permit(
      :feedback,
      :internal_notes,
      :articulation_score,
      :knowledge_score,
      results_attributes: [:notes, :score, :id]
    )
  end

end
