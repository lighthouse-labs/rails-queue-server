class QueueChannel < ApplicationCable::Channel

  include Rails.application.routes.url_helpers

  def subscribed
    if current_user&.is_a?(Teacher)
      stream_from "queue"
      location_name = current_user.location.name
      stream_from "assistance-#{location_name}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def cancel_assistance_request(data)
    ar = AssistanceRequest.find_by id: data["request_id"]
    if ar&.cancel
      RequestQueue::BroadcastUpdate.call(program: Program.first)
      UserChannel.broadcast_to ar.requestor, type: "AssistanceEnded"
      update_students_in_queue(ar.assistor_location)
    end
  end

  def cancel_assisting(data)
    assistance = Assistance.find_by id: data["assistance_id"]
    RequestQueue::CancelAssistance.call(
      assistance: assistance,
      user:       current_user
    )
  end

  def start_assisting(data)
    assistance_request = AssistanceRequest.find(data["request_id"])
    RequestQueue::StartAssistance.call(
      assistance_request: assistance_request,
      assistor:           current_user
    )
  end

  def start_evaluating(data)
    evaluation = Evaluation.find_by id: data["evaluation_id"]
    if evaluation&.grabbable_by?(current_user)
      evaluation.teacher = current_user
      if evaluation.transition_to(:in_progress)
        BroadcastMarking.call(evaluation:          evaluation,
                              evaluator:           current_user,
                              user:                current_user,
                              edit_evaluation_url: edit_project_evaluation_path(evaluation.project, evaluation))
      end
    end
  end

  def cancel_evaluating(data)
    evaluation = Evaluation.find_by id: data["evaluation_id"]
    if evaluation&.can_requeue?
      evaluation.teacher = nil
      BroadcastMarking.call(evaluation: evaluation) if evaluation.transition_to(:pending)
    end
  end

  def cancel_interviewing(data)
    interview = TechInterview.find_by id: data["interview_id"]
    StopTechInterview.call(
      tech_interview: interview,
      user:           current_user
    )
  end

end
