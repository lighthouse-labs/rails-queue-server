class QueueController < ApplicationController

  before_action :teacher_required, except: :day_activities
  before_action :super_admin_required, only: :update_settings

  def index
    queue_tasks = current_user.admin? ? QueueTask.open_or_in_progress_tasks : QueueTask.teachers_queue_or_in_progress(current_user)
    queue_tasks += Evaluation.incomplete.exclude_cancelled.student_priority
    queue_tasks += TechInterview.in_progress
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def show
    user = User.find_by(id: params[:id])
    queue_tasks = user.queue_tasks.this_month
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

  def teachers
    teachers = Octopus.using_group(:program_shards) do
      teachers = Teacher.on_duty
      render json: teachers, each_serializer: UserSerializer, root: 'teachers'
    end
  end

  def day_activities
    render json: current_user.visible_bootcamp_activities.assistance_worthy.pluck(:name, :day, :id).group_by { |d| d[1] }
  end

  def settings
    queue_settings = Program.first.settings['task_router_settings']
    queue_settings ||= {}
    render json: { queueSettings: queue_settings }
  end

  def update_settings
    program = Program.first
    program.settings['task_router_settings'] = queue_settings_params
    if program.save!
      render json: { message: 'Settings Updated' }, status: :ok
    else
      render json: { message: 'Unable to Update Queue Settings' }, status: :internal_server_error
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
