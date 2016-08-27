class TeachersController < ApplicationController

  before_action :load_teacher, except: [:index]

  def index
    @locations = Location.all.order(:name)
    @teachers  = Teacher.all
    if params[:location_id] && @location = Location.find_by(id: params[:location_id])
      if @location.satellite? && @supporting_location = @location.supported_by_location
        @teachers = @teachers.where(location_id: [@location.id, @supporting_location.id])
      else
        @teachers = @teachers.where(location_id: @location.id)
      end
    end

  end

  def feedback
    @feedback = @teacher.feedbacks.find_or_create_by(student: current_user, feedbackable: nil)
    render 'feedbacks/modal_content', layout: false
  end

  def remove_mentorship
    if admin?
      @teacher.mentor = false
      @teacher.save
    end
    render nothing: true
  end

  def add_mentorship
    if admin?
      @teacher.mentor = true
      @teacher.save
    end
    render nothing: true
  end

  private

  def load_teacher
    @teacher = Teacher.find(params[:id])
  end

end
