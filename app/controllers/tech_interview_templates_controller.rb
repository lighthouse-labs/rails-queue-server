class TechInterviewTemplatesController < ApplicationController

  def index
    @interview_templates = TechInterviewTemplate.all
  end

  def show
    @interview_template = TechInterviewTemplate.find params[:id]

    if student?
      @result = @interview_template.interview_for(current_user)
    end
  end

end
