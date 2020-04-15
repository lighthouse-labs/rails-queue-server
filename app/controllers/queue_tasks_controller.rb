class QueueTasksController < ApplicationController

  before_action :teacher_required

  def show
    respond_to do |format|
      user = User.find_by_id(params[:user_id])
      format.html
      format.json do
        render json:  {
          queue: QueueTasksSerializer.new(user.queue_tasks).as_json,
          students: 5,
          in_progress: 10,
        }
      end
    end
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
    render json: cohorts, each_serializer: EvaluationSerializer, root: 'evaluations'
  end

  # TODO: Turn it into an interactor instead of controller doing a whole bunch of logic
  def provided_assistance
    respond_to do |format|
      format.json do
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
    end
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
