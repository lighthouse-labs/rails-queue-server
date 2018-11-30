class QueueController < ApplicationController

  before_action :teacher_required

  def show
    # only one program. Yes, this breaks in the future if we ever have multiple programs in the db
    # but that's a problem everywhere
    @program = Program.first

    respond_to do |format|
      format.html
      format.json do
        # 15ms-30ms response vs 900-1200 ms range response on my localhost, due to reading from cache - KV
        render json: full_queue_json(params[:force] == 'true')
      end
    end
  end

  def provided_assistance
    respond_to do |format|
      format.json do
        student = Student.find params[:student_id]
        assistance_request = AssistanceRequest.new(requestor: student, reason: "Offline assistance requested")
        if assistance_request.save
          assistance_request.start_assistance(current_user)
          assistance = assistance_request.reload.assistance
          assistance.end(params[:notes], params[:notify], params[:rating])
          puts "responding"
          render json: { success: true }
        else
          render json: { success: false, error: assistance_request.errors.full_messages.first }, status: :forbidden
        end
        puts "queue update starting"
        RequestQueue::BroadcastUpdate.call(program: Program.first)
      end
    end
  end

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

  def full_queue_json(force = false)
    queue_json = queue_json(force)
    loc_json = MyLocationSerializer.new(current_user.location).to_json
    %({"queue":#{queue_json},"myLocation":#{loc_json}})
  end

  def queue_json(force = false)
    $redis_pool.with do |conn|
      if force
        json = QueueSerializer.new(@program, root: false).to_json
        conn.set("program:#{@program.id}:queue", json)
      else
        json = conn.get("program:#{@program.id}:queue")
        unless json
          json = QueueSerializer.new(@program, root: false).to_json
          conn.set("program:#{@program.id}:queue", json)
        end
      end
      json
    end
  end

  def teacher_required
    unless teacher?
      respond_to do |format|
        format.html do
          redirect_to(:root, alert: 'Not allowed.')
        end
        format.json do
          render json: { error: 'Not Allowed.' }
        end
      end
    end
  end

end
