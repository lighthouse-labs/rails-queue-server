class TechInterviewTemplatesController < ApplicationController

  def index
    @interview_templates = TechInterviewTemplate.active
  end

  def show
    if params[:cohort].present?
      @cohort = Cohort.find params[:cohort]
      if session[:cohort_id] != @cohort.id
        session[:cohort_id] = @cohort.id
        flash[:notice] = "You have switched to #{@cohort.name}"
      end
      redirect_to tech_interview_template_path params[:id]
    end

    @interview_template = TechInterviewTemplate.find params[:id]

    @result = @interview_template.interview_for(current_user) if student?
  end

end
