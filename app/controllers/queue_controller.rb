class QueueController < ApplicationController
  
  skip_before_action :verify_authenticity_token
  before_action :teacher_required, except: [:index, :teachers]
  before_action :super_admin_required, only: :update_settings

  def index
    if @current_user['access'].include?('admin')
      queue_tasks = QueueTask.pending_or_in_progress
    elsif @current_user['access'].include?('teacher')
      queue_tasks = QueueTask.teachers_queue_or_in_progress(@current_user['uid'])
    else
      queue_tasks = QueueTask.finished.assisting(@current_user['uid'])
    end
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def show
    user = first_compass_instance_result { User.find_by(uid: params[:id]) }
    queue_tasks = user.queue_tasks.this_month
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def create
    #  create ar and qt
    result = NationalQueue::RequestAssistance.call(
      requestor:    requestor_params,
      request:      request_params
    )
    if result.success?
      render json: { queueSettings: queue_settings }
    else
      render json: { message: 'Unable to Post Request' }, status: :internal_server_error
    end
  end

  def teachers
    teachers = all_compass_instance_results { Teacher.on_duty }
    # while multiple shards are used for teacher's combine duplicate teachers across shards
    teachers = teachers.map{ |teacher| [teacher.uid, teacher] }.to_h.values
    render json: teachers, each_serializer: UserSerializer, root: 'teachers'
  end

  def settings
    queue_settings = CompassInstance.find_by(id: @current_user['compass_instance_id'])&.settings['task_router_settings']
    queue_settings ||= {}
    render json: { queueSettings: queue_settings }
  end

  def update_settings
    compass_instance = CompassInstance.find_by(id: @current_user['compass_instance_id'])
    compass_instance.settings['task_router_settings'] = queue_settings_params
    if compass_instance.save!
      render json: { message: 'Settings Updated' }, status: :ok
    else
      render json: { message: 'Unable to Update Queue Settings' }, status: :internal_server_error
    end
  end

  private

  def teacher_required
    unless @current_user['access'].include?("teacher")
      render json: { error: 'Not Allowed.' }
    end
  end

  def super_admin_required
    unless @current_user['access'].include?("super_admin")
      render json: { error: 'Not Allowed.' }
    end
  end

  def requestor_params
    info_options = params.require(:requestor)[:info].try(:permit!)
    social_options = params.require(:requestor)[:social].try(:permit!)
    params.require(:requestor).permit(:uid, :fullName, :pronoun, :avatarUrl, :socials, :info, :infoUrl, :access).merge(:info => info_options).merge(:social => social_options)
  end

  def request_params
    info_options = params.require(:request)[:info].try(:permit!)
    params.require(:request).permit(:reason, :resourceUuid, :resourceLink, :resourceName, :resourceType, :finishResourceUrl, :route).merge(:info => info_options)
  end

  def queue_settings_params
    params.require(:queue_settings).permit(:task_penalty, :max_queue_size, :rating_multiplier, :assistance_penalty, :evaluation_penalty, :same_location_bonus, :tech_interview_penalty, :desired_task_assignment)
  end

end
