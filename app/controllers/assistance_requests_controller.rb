class AssistanceRequestsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :credentials_required

  def index
    
  end

  def show
    user = User.find_by(id: params[:id])
    queue_tasks = user.queue_tasks.this_month
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def create
    #  create ar and qt
    if params[:assistor].present?
      assistor = first_compass_instance_result { User.find_by(uid: assistor_params[:uid]) }
      render(json: { message: 'Invalid Assistor'}, status: :internal_server_error) unless assistor.present?
    end
    result = NationalQueue::RequestAssistance.call(
      requestor:    requestor_params,
      request:      request_params,
      assistor:     assistor,
      type:         'ResourceRequest',
      compass_instance: @compass_instance
    )
    if result.success?
      render json: { message: 'Request created'}
    else
      render json: { message: 'Unable to Post Request' }, status: :internal_server_error
    end
  end

  def update
    assitance_request = AssistanceRequest.with_request_id(request_params[:id]).first
    render json: { message: 'Unable to Update Request' }, status: :internal_server_error unless assitance_request.present?
    
    if params[:assistor].present?
      assistor =  first_compass_instance_result { User.find_by(uid: assistor_params[:uid]) }
      render(json: { message: 'Invalid Assistor'}, status: :internal_server_error) unless assistor.present?
      type = assitance_request.in_progress? ? 'finish_assistance' : 'start_assistance'
    else
      type = assitance_request.in_progress? ? 'cancel_assistance' : 'cancel'
    end
    result = NationalQueue::UpdateRequest.call(
      assistor: assistor,
      options:   {
        type:       type,
        request_id: assitance_request.id
      }
    )
    if result.success?
      render json: { message: 'Request updated'}
    else
      render json: { message: 'Unable to Update Request' }, status: :internal_server_error
    end
  end

  private

  def credentials_required
    @compass_instance = CompassInstance.find_by(key: credentials_params[:key])
    if !@compass_instance || BCrypt::Password.new(@compass_instance&.secret) != credentials_params[:secret]
      render json: { error: 'Incorrect key or secret.' }
    end
  end

  def credentials_params
    params.require(:credentials).permit(:key, :secret)
  end

  def requestor_params
    info_options = params.require(:requestor)[:info].try(:permit!)
    social_options = params.require(:requestor)[:social].try(:permit!)
    access_options = params.require(:requestor)[:access].try(:permit!)
    params.require(:requestor).permit(:uid, :fullName, :pronoun, :avatarUrl, :socials, :info, :infoUrl, :access).merge(info: info_options, social: social_options, access: access_options)
  end

  def assistor_params
    info_options = params.require(:assistor)[:info].try(:permit!)
    social_options = params.require(:assistor)[:social].try(:permit!)
    access_options = params.require(:assistor)[:access].try(:permit!)
    params.require(:assistor).permit(:uid, :fullName, :pronoun, :avatarUrl, :socials, :info, :infoUrl, :access).merge(info: info_options, social: social_options, access: access_options)
  end

  def request_params
    info_options = params.require(:request)[:info].try(:permit!)
    params.require(:request).permit(:reason, :id, :resourceUuid, :resourceLink, :resourceName, :resourceType, :finishResourceUrl, :route).merge(info: info_options)
  end

end
