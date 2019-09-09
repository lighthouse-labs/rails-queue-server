class TeachersController < ApplicationController

  before_action :load_teacher, except: [:index]
  DEFAULT_PER = 10

  def index
    @locations = Location.all.order(:name)
    @teachers  = Teacher.active.all
    if params[:location_id] && @location = Location.find_by(id: params[:location_id])
      @teachers = if @location.satellite? && @supporting_location = @location.supported_by_location
                    @teachers.where(location_id: [@location.id, @supporting_location.id])
                  else
                    @teachers.where(location_id: @location.id)
                  end
    end
    @paginated_teachers = @teachers.page(params[:page]).per(DEFAULT_PER)
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
    @teacher = Teacher.active.find(params[:id])
  end

end
