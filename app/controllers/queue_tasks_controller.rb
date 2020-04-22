class QueueTasksController < ApplicationController

  before_action :teacher_required, except: :day_activities

  def show
    queue_tasks = current_user.admin? ? QueueTask.open_or_in_progress_tasks : QueueTask.teachers_queue_or_in_progress(current_user)
    queue_tasks += Evaluation.incomplete.student_priority
    queue_tasks += TechInterview.in_progress
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def students
    # Can filter for what students the teacher has access to in the future
    cohorts = Program.first.cohorts.is_active
    students = Student.joins(:cohort).merge(cohorts).distinct.to_a
    render json: students, each_serializer: QueueStudentSerializer, root: 'students'
  end

  def cohorts
    # Can filter for what students the teacher has access to in the future
    cohorts = Program.first.cohorts.is_active
    render json: cohorts, each_serializer: QueueCohortStatusSerializer, root: 'cohorts'
  end

  def day_activities
    render json: current_user.visible_bootcamp_activities.assistance_worthy.pluck(:name, :day, :id).group_by { |d| d[1] }
  end

  # TODO: Turn it into an interactor instead of controller doing a whole bunch of logic
  def provided_assistance
    student = Student.find params[:student_id]
    assistance_request = AssistanceRequest.new(requestor: student, reason: "Offline assistance requested")
    if assistance_request.save
      assistance_request.start_assistance(current_user)
      assistance = assistance_request.reload.assistance
      assistance.end(params[:notes], params[:notify], params[:rating])
      render json: { success: true }
    else
      render json: { success: false, error: assistance_request.errors.full_messages.first }, status: :forbidden
    end
    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

  private

  def teacher_required
    unless teacher?
      respond_to do |format|
        format.html { redirect_to(:root, alert: 'Not allowed.') }
        format.json { render json: { error: 'Not Allowed.' } }
      end
    end
  end

end
