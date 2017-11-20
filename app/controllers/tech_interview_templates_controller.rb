class TechInterviewTemplatesController < ApplicationController

  def index
    @interview_templates = TechInterviewTemplate.all
  end

  def show
    if params[:cohort] != nil
      @cohort = Cohort.find params[:cohort]
      session[:cohort_id] = @cohort.id
    end

    @interview_template = TechInterviewTemplate.find params[:id]

    @result = @interview_template.interview_for(current_user) if student?
  end

end
