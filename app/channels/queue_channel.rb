class QueueChannel < ApplicationCable::Channel

  def subscribed
    stream_from "queue"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def cancel_assistance_request(data)
    ar = AssistanceRequest.find_by id: data["request_id"]
    if ar&.cancel
      BroadcastQueueUpdate.call(program: Program.first)
      UserChannel.broadcast_to ar.requestor, type: "AssistanceEnded"
      update_students_in_queue(ar.assistor_location)
    end
  end

  def stop_assisting(data)
    assistance = Assistance.find_by id: data["assistance_id"]
    if assistance&.destroy
      student = assistance.assistee
      UserChannel.broadcast_to student, type:   "AssistanceRequested",
                                        object: student.position_in_queue

      BroadcastQueueUpdate.call(program: Program.first)
      teacher_available(current_user)
      update_students_in_queue(assistance.assistance_request.assistor_location)
    end
  end

  def start_assisting(data)
    ar = AssistanceRequest.find_by id: data["request_id"]
    if ar&.start_assistance(current_user)
      # technically it should not do Program.first here, but wtv. Shouldn't cause issues - KV
      # I do need to figure out what object is better to send in there actually
      BroadcastQueueUpdate.call(program: Program.first)
      UserChannel.broadcast_to ar.requestor, type: "AssistanceStarted", object: UserSerializer.new(current_user).as_json
      teacher_busy(current_user)
      update_students_in_queue(ar.assistor_location)
    end
  end

end
