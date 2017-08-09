class AssistanceRequestAndTechInterviewDestroyer

  def run
    Rails.logger.info "AssistanceRequestAndTechInterviewDestroyer Running..."

    remove_assistance_requests
    remove_tech_interviews

    Rails.logger.info "AssistanceRequestAndTechInterviewDestroyer Complete!"
  end

  private

  def remove_assistance_requests
    Rails.logger.info "Removing Assistance Requests"
    assistance_requests = AssistanceRequest.open_requests

    Rails.logger.info "#{assistance_requests.count} entries found."
    assistance_requests.each do |ar|
      ar.cancel
      ActionCable.server.broadcast "assistance-#{ar.requestor.cohort.location.name}",
                                   type:   "CancelAssistanceRequest",
                                   object: AssistanceRequestSerializer.new(ar, root: false).as_json
      UserChannel.broadcast_to ar.requestor, type: "AssistanceEnded"
    end
  end

  def remove_tech_interviews
    Rails.logger.info "Removing Tech Interviews"
    interviews = TechInterview.where(started_at: nil)

    Rails.logger.info "#{interviews.count} entries found."
    interviews.delete_all
  end

end
