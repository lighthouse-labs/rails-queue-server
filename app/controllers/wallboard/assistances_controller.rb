class Wallboard::AssistancesController < Wallboard::BaseController

  def index
    render json: RequestQueue::FetchQueueJson.call(
          rebuild_cache: params[:force] == 'true',
          program: @program).json
  end

  def assistances_params
    params.require(:location)
  end

end
