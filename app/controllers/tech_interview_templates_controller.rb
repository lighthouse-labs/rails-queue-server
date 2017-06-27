class TechInterviewTemplatesController < ApplicationController

  def index
    @interview_templates = TechInterviewTemplate.all
  end

  def show
    @interview_template = TechInterviewTemplate.find params[:id]

    @result = @interview_template.interview_for(current_user) if student?
  end

end
