class AssistanceChannel < ApplicationCable::Channel

  def subscribed
    stream_from "assistance-#{params[:location]}"
  end

  def start_assisting(data)
    ar = AssistanceRequest.find(data["request_id"])
    if ar.start_assistance(current_user)
      location_name = ar.assistor_location.name
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "AssistanceStarted",
                                                                  object: AssistanceSerializer.new(ar.reload.assistance, root: false).as_json
      # technically it should not do Program.first here, but wtv. Shouldn't cause issues - KV
      # I do need to figure out what object is better to send in there actually
      BroadcastQueueUpdate.call(program: Program.first)
      UserChannel.broadcast_to ar.requestor, type: "AssistanceStarted", object: UserSerializer.new(current_user).as_json

      teacher_busy(current_user)
      update_students_in_queue(ar.assistor_location)
    end
  end

  def end_assistance(data)
    assistance = Assistance.find data["assistance_id"]
    assistance.end(data["notes"], data["notify"], data["rating"].to_i)

    location_name = assistance.assistance_request.assistor_location.name
    ActionCable.server.broadcast "assistance-#{location_name}", type:   "AssistanceEnded",
                                                                object: AssistanceSerializer.new(assistance, root: false).as_json
    BroadcastQueueUpdate.call(program: Program.first)
    UserChannel.broadcast_to assistance.assistance_request.requestor, type: "AssistanceEnded"
    teacher_available(current_user)
  end

  def cancel_assistance_request(data)
    ar = AssistanceRequest.find data["request_id"]
    if ar&.cancel
      location_name = ar.assistor_location.name
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "CancelAssistanceRequest",
                                                                  object: AssistanceRequestSerializer.new(ar, root: false).as_json

      BroadcastQueueUpdate.call(program: Program.first)
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

      BroadcastQueueUpdate.call(program: Program.first)
      teacher_available(current_user)
      update_students_in_queue(assistance.assistance_request.assistor_location)
    end
  end

  def provided_assistance(data)
    student = Student.find data["student_id"]
    assistance_request = AssistanceRequest.new(requestor: student, reason: "Offline assistance requested")
    BroadcastQueueUpdate.call(program: Program.first)
    if assistance_request.save
      assistance_request.start_assistance(current_user)
      assistance = assistance_request.reload.assistance
      assistance.end(data["notes"], data["notify"], data["rating"])
    end
  end

end
