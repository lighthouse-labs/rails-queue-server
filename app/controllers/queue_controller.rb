class QueueController < ApplicationController

  before_action :teacher_required, except: :day_activities
  before_action :super_admin_required, only: :update_settings

  def index
    queue_tasks = @current_user['access'].include?('admin') ? QueueTask.pending_or_in_progress : QueueTask.teachers_queue_or_in_progress(@current_user['uid'])
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def show
    user = User.find_by(id: params[:id])
    queue_tasks = user.queue_tasks.this_month
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def teachers
    teachers = Octopus.using_group(:program_shards) do
      teachers = Teacher.on_duty
      render json: teachers, each_serializer: UserSerializer, root: 'teachers'
    end
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
    unless @current_user['access'].include?("teacher")
      respond_to do |format|
        format.html { redirect_to(:root, alert: 'Not allowed.') }
        format.json { render json: { error: 'Not Allowed.' } }
      end
    end
  end

  def super_admin_required
    unless @current_user['access'].include?("super_admin")
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
