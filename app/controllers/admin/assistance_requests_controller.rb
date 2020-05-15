class AssistanceRequestsController < Admin::BaseController

  before_action :teacher_required, except: :day_activities
  before_action :super_admin_required, only: :update_settings

  def index
    queue_tasks = current_user.admin? ? QueueTask.pending_or_in_progress : QueueTask.teachers_queue_or_in_progress(current_user)
    queue_tasks += Evaluation.incomplete.exclude_cancelled.student_priority
    queue_tasks += TechInterview.in_progress
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def show
    user = User.find_by(id: params[:id])
    queue_tasks = user.queue_tasks.this_month
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
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

  def super_admin_required
    unless current_user.super_admin?
      respond_to do |format|
        format.html { redirect_to(:root, alert: 'Not allowed.') }
        format.json { render json: { error: 'Not Allowed.' } }
      end
    end
  end

  def queue_settings_params
    params.require(:queue_settings).permit(:task_penalty, :max_queue_size, :rating_multiplier, :assistance_penalty, :evaluation_penalty, :same_location_bonus, :tech_interview_penalty, :desired_task_assignment)
  end

end
