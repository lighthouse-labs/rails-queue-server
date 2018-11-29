class AssistanceChannel < ApplicationCable::Channel

  def subscribed
    stream_from "assistance-#{params[:location]}"
  end

  def cancel_assistance_request(data)
    ar = AssistanceRequest.find data["request_id"]
    if ar&.cancel
      location_name = ar.assistor_location.name
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "CancelAssistanceRequest",
                                                                  object: AssistanceRequestSerializer.new(ar, root: false).as_json

      RequestQueue::BroadcastUpdate.call(program: Program.first)
      UserChannel.broadcast_to ar.requestor, type: "AssistanceEnded"
      update_students_in_queue(ar.assistor_location)
    end
  end

  def stop_assisting(data)
    assistance = Assistance.find data["assistance_id"]
    student = assistance.assistee
    if assistance&.destroy
      location_name = assistance.assistance_request.assistor_location.name
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "StoppedAssisting",
                                                                  object: AssistanceSerializer.new(assistance).as_json

      UserChannel.broadcast_to student, type:   "AssistanceRequested",
                                        object: student.position_in_queue

      RequestQueue::BroadcastUpdate.call(program: Program.first)
      teacher_available(current_user)
      update_students_in_queue(assistance.assistance_request.assistor_location)
    end
  end

end
