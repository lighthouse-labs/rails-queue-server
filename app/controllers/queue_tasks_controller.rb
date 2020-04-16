class QueueTasksController < ApplicationController

  before_action :teacher_required

  def show
    queue_tasks = QueueTask.teachers_queue_or_in_progress(current_user)
    render json: queue_tasks, each_serializer: QueueTaskSerializer 
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

  def evaluations
    # Can filter for what students the teacher has access to in the future
    evaluations = Evaluation.incomplete.student_priority
    render json: evaluations, each_serializer: EvaluationSerializer, root: 'evaluations'
  end

  def tech_interviews
    # Can filter for what students the teacher has access to in the future
    tech_interviews = TechInterview.in_progress
    render json: tech_interviews, each_serializer: TechInterviewSerializer, root: 'techInterviews'
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

  # TODO: Turn it into an interactor instead of controller doing a whole bunch of logic
  def end_assistance
    respond_to do |format|
      format.json do
        assistance = Assistance.find params[:assistance_id]
        assistance.end(params[:notes], params[:notify], params[:rating].to_i)
        render json: { success: true }
        BroadcastAssistanceEndWorker.perform_async(assistance.id)
      end
    end
  end

  # TODO: Turn it into an interactor instead of controller doing a whole bunch of logic
  def start_evaluation
    respond_to do |format|
      format.json do
        evaluation = Evaluation.find params[:evaluation_id]
        evaluation.teacher = current_user
        evaluation.transition_to!(:in_progress)
        BroadcastMarking.call(evaluation: evaluation)
        render json: {
          success:    true,
          evaluation: EvaluationSerializer.new(evaluation)
        }
      end
    end
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
