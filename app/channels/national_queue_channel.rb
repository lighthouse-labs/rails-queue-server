class NationalQueueChannel < ApplicationCable::Channel

  def subscribed
    stream_from 'student-national-queue'
    if current_user&.is_a?(Teacher)
      stream_from 'teacher-national-queue'
    end
    @update_sequence = 0;
  end

  def unsubscribed
    # cleanup
  end

  def request_assistance(data)
    NationalQueue::RequestAssistance.call(
      requestor:   current_user,
      reason:      data["reason"],
      activity_id: data["activity_id"]
    )
  end

  def cancel_assistance_request(data)
    NationalQueue::UpdateRequest.call(
      options: {
        type: 'cancel',
        request_id: data["request_id"]
      }
    )
  end

  def cancel_assisting(data)
    NationalQueue::UpdateRequest.call(
      options: {
        type: 'cancel_assistance',
        request_id: data["request_id"]
      }
    )
  end

  def start_assisting(data)
    NationalQueue::UpdateRequest.call(
      options: {
        type: 'start_assistance',
        request_id: data["request_id"],
        assistor: current_user
      }
    )
  end

  def start_evaluating(data)
    # evaluation = Evaluation.find_by id: data["evaluation_id"]
    # if evaluation&.grabbable_by?(current_user)
    #   evaluation.teacher = current_user
    #   if evaluation.transition_to(:in_progress)
    #     BroadcastMarking.call(evaluation:          evaluation,
    #                           evaluator:           current_user,
    #                           user:                current_user,
    #                           edit_evaluation_url: edit_project_evaluation_path(evaluation.project, evaluation))
    #   end
    # end
  end

  def cancel_evaluating(data)
    # evaluation = Evaluation.find_by id: data["evaluation_id"]
    # if evaluation&.can_requeue?
    #   evaluation.teacher = nil
    #   BroadcastMarking.call(evaluation: evaluation) if evaluation.transition_to(:pending)
    # end
  end

  def cancel_interviewing(data)
    # interview = TechInterview.find_by id: data["interview_id"]
    # StopTechInterview.call(
    #   tech_interview: interview,
    #   user:           current_user
    # )
  end

end
