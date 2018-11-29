class QueueController < ApplicationController

  before_action :teacher_required

  def show
    respond_to do |format|
      format.html
      format.json {
        render json: {
          queue: QueueSerializer.new(current_user, root: false),
          myLocation: MyLocationSerializer.new(current_user.location)
        }
      }
    end
  end

  def provided_assistance
    respond_to do |format|
      format.json {
        student = Student.find params[:student_id]
        assistance_request = AssistanceRequest.new(requestor: student, reason: "Offline assistance requested")
        if assistance_request.save
          assistance_request.start_assistance(current_user)
          assistance = assistance_request.reload.assistance
          assistance.end(params[:notes], params[:notify], params[:rating])
          puts "responding"
          render json: { success: true }
        else
          render json: { success: false, error: assistance_request.errors.full_messages.first }, status: 403
        end
        puts "queue update starting"
        RequestQueue::BroadcastUpdate.call(program: Program.first)
      }
    end
  end

  def end_assistance
    respond_to do |format|
      format.json {
        assistance = Assistance.find params[:assistance_id]
        assistance.end(params[:notes], params[:notify], params[:rating].to_i)

        render json: { success: true }

        BroadcastAssistanceEndWorker.perform_async(assistance.id)
      }
    end
  end

  def start_evaluation
    respond_to do |format|
      format.json {
        evaluation = Evaluation.find params[:evaluation_id]
        evaluation.teacher = current_user
        evaluation.transition_to!(:in_progress)
        BroadcastMarking.call(evaluation: evaluation)
        render json: {
          success: true,
          evaluation: EvaluationSerializer.new(evaluation)
        }
      }
    end
  end

  private

  def teacher_required
    unless teacher?
      respond_to do |format|
        format.html {
          redirect_to(:root, alert: 'Not allowed.')
        }
        format.json {
          render json: { error: 'Not Allowed.' }
        }
      end
    end
  end

end
